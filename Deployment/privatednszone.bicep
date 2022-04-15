param primary_location string = 'centralus'
param prefix string = 'platform'
param priVnetId string
param serviceIp string

var priNetworkPrefix = toLower('${prefix}-${primary_location}')

resource privatednszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'contoso.com'
  properties: {
    
  }
}

resource demoARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: 'demo'
  parent: privatednszone
  properties: {
    aRecords: [
      {
      ipv4Address: serviceIp
      }
    ]
    
  }
}

resource dnsvnetlinkprimary 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${priNetworkPrefix}-vnetlink'
  location: primary_location
  parent: privatednszone
  properties: {
    registrationEnabled: false
    virtualNetwork: { 
      id: priVnetId
    }
  }
}
