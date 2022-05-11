param prefix string = 'platform'
param appEnvironment string = 'dev'
param lastUpdated string = utcNow('u')
param location string = 'Global'
param serviceIp string
param branch string
param version string


var stackName = '${prefix}${appEnvironment}'
var tags = {
  'stack-name': 'cch-aks'
  'stack-environment': appEnvironment
  'stack-branch': branch
  'stack-version': version
  'stack-last-updated': lastUpdated
  'stack-sub-name': 'demo'
}

resource profiles_cch_frontdoor_name_resource 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: '${stackName}-FD'
  location: location
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource ftd 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: '${stackName}-FTD'
  location: location
  tags: tags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource aksprofile 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: ftd
  name: '${stackName}-aks'
  location: location
  tags: tags
  properties: {
    enabledState: 'Enabled'
  }
}

resource aksprend 'Microsoft.Cdn/profiles/afdendpoints@2021-06-01' = {
  parent: ftd
  name: '${stackName}-endpoint'
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
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 240
    }
    sessionAffinityState: 'Disabled'
  }
}

resource origindefault 'Microsoft.Cdn/profiles/origingroups@2021-06-01' = {
  parent: ftd
  name: '${stackName}-default'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
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
    originHostHeader: serviceIp
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource wafpolicy 'Microsoft.Cdn/cdnWebApplicationFirewallPolicies@2021-06-01' = {
  name: '${stackName}-WAF-Policy'
  location: location
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties:{
    policySettings:{
      enabledState: 'Enabled'
      mode: 'Detection'
    }
    customRules:{
      rules: []
    }
    managedRules:{
      managedRuleSets: []
    }
  }
}

resource originpath 'Microsoft.Cdn/profiles/origingroups/origins@2021-06-01' = {
  parent: origindefault
  name: '${stackName}-originpath'
  properties: {
    hostName: 'cch03dev-apim.azure-api.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'cch03dev-apim.azure-api.net'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
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
              id: aksprofile.id
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

resource WAFpolicy 'Microsoft.Cdn/profiles/securitypolicies@2021-06-01' = {
  parent: ftd
  name: '${stackName}-WAF-policy'
  properties: {
    parameters: {
      wafPolicy: {
        id: wafpolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: aksprend.id
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

resource defaultroute 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: aksprofile
  name: '${stackName}-default-route'
  properties: {
    customDomains: []
    originGroup: {
      id: origindefault.id
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

resource aksroute 'Microsoft.Cdn/profiles/afdendpoints/routes@2021-06-01' = {
  parent: aksprofile
  name: '${stackName}-aks-route'
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
