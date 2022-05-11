param prefix string = 'platform'
param appEnvironment string = 'dev'
param lastUpdated string = utcNow('u')
param location string = 'Global'
param priVnetId string
param serviceIp string
param branch string
param version string

var tags = {
  'stack-name': 'cch-aks'
  'stack-environment': appEnvironment
  'stack-branch': branch
  'stack-version': version
  'stack-last-updated': lastUpdated
  'stack-sub-name': 'demo'
}

var priNetworkPrefix = toLower('${prefix}-global')

resource privatednszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'contoso.com'
  tags: tags
  location: location
  properties: {
    
  }
}

resource demoARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'demo'
  parent: privatednszone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: serviceIp
      }
    ]
    
  }
}

resource dnsvnetlinkprimary 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${priNetworkPrefix}-vnetlink'
  parent: privatednszone
  location: location
  properties: {
    registrationEnabled: false
    virtualNetwork: { 
      id: priVnetId
    }
  }
}


