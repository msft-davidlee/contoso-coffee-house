param prefix string = 'platform'
param appEnvironment string = 'dev'
param lastUpdated string = utcNow('u')
param location string = 'Global'
param serviceIp string
param branch string
param version string
param apimurl string

var stackName = '${prefix}${appEnvironment}'
var tags = {
  'stack-name': 'cch-aks'
  'stack-environment': appEnvironment
  'stack-branch': branch
  'stack-version': version
  'stack-last-updated': lastUpdated
  'stack-sub-name': 'demo'
}

resource ftd 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: '${stackName}-afd'
  location: location
  tags: tags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}
var aksafd = '${stackName}-aks-${uniqueString(resourceGroup().id)}'
resource aksendpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: ftd
  name: aksafd
  location: location
  tags: tags
  properties: {
    enabledState: 'Enabled'
  }
}

var apimafd = '${stackName}-endpoint-${uniqueString(resourceGroup().id)}'
resource apimendpoint 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: ftd
  name: apimafd
  location: location
  tags: tags
  properties: {
    enabledState: 'Enabled'
  }
}

resource originaks 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: ftd
  name: '${stackName}-originaks'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/health'
      probeRequestType: 'GET'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 240
    }
    sessionAffinityState: 'Disabled'
  }
}

resource originapim 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: ftd
  name: '${stackName}-apim'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/rewards/health'
      probeRequestType: 'GET'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource akspath 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: originaks
  name: '${stackName}-akspath'
  properties: {
    hostName: serviceIp
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'demo.contoso.com'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource originpath 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: originapim
  name: '${stackName}-originpath'
  properties: {
    hostName: '${stackName}-apim.azure-api.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: '${stackName}-apim.azure-api.net'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource wafpolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: '${stackName}waf'
  location: location
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Detection'
    }
    customRules: {
      rules: []
    }
    managedRules: {
      managedRuleSets: []
    }
  }
}

resource akspolicy 'Microsoft.Cdn/profiles/securitypolicies@2021-06-01' = {
  parent: ftd
  name: '${stackName}-aks-policy'
  properties: {
    parameters: {
      wafPolicy: {
        id: wafpolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: aksendpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
      type: 'WebApplicationFirewall'
    }
  }
}

resource aksroute 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: aksendpoint
  name: '${stackName}aksroute'
  properties: {
    customDomains: []
    originGroup: {
      id: originaks.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

resource apimroute 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: apimendpoint
  name: '${stackName}apimroute'
  properties: {
    customDomains: []
    originGroup: {
      id: originapim.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}
