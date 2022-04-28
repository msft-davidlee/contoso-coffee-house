param prefix string
param appEnvironment string = 'dev'
param branch string
param location string
param sharedResourceGroup string
param keyVaultName string
param kubernetesVersion string = '1.23.3'
param subnetId string
param aksMSIId string
param version string
param lastUpdated string = utcNow('u')
param nodesResourceGroup string
param subnetAPIMId string
param publisherName string = 'ContosoOwner'
param publisherEmail string = 'rewards@contoso.com'
param jwtConfigAppId string
param jwtConfigTenantId string
param urlapi string = 'demo.contoso.com'

var stackName = '${prefix}${appEnvironment}'
var tags = {
  'stack-name': 'cch-aks'
  'stack-environment': appEnvironment
  'stack-branch': branch
  'stack-version': version
  'stack-last-updated': lastUpdated
  'stack-sub-name': 'demo'
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: stackName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    ImmediatePurgeDataOn30Days: true
    IngestionMode: 'ApplicationInsights'
  }
}

var queueName = 'orders'

resource sbu 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: '${stackName}sb'
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
}

output serviceBusName string = sbu.name

resource sbuSenderAuthRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-06-01-preview' = {
  parent: sbu
  name: 'Sender'
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource sbuListenAuthRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-06-01-preview' = {
  parent: sbu
  name: 'Listener'
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource sbuQueue 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
  parent: sbu
  name: queueName
  properties: {
    lockDuration: 'PT30S'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    enablePartitioning: false
    enableExpress: false
  }
}

var sqlUsername = 'app'

//https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter?tabs=azure-cli#use-getsecret-function

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
  scope: resourceGroup(subscription().subscriptionId, sharedResourceGroup)
}

module sql './sql.bicep' = {
  name: 'deploy-${appEnvironment}-${version}-sql'
  params: {
    subnetId: subnetId
    stackName: stackName
    sqlPassword: kv.getSecret('contoso-customer-service-sql-password')
    tags: tags
    location: location
  }
}

resource wks 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: stackName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-08-01' = {
  name: stackName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksMSIId}': {}
    }
  }
  properties: {
    dnsPrefix: prefix
    kubernetesVersion: kubernetesVersion
    networkProfile: {
      networkPlugin: 'kubenet'
      serviceCidr: '10.250.0.0/16'
      dnsServiceIP: '10.250.0.10'
    }
    // We can provide a name but it cannot be existing
    // https://docs.microsoft.com/en-us/azure/aks/faq#can-i-provide-my-own-name-for-the-aks-node-resource-group
    nodeResourceGroup: nodesResourceGroup
    agentPoolProfiles: [
      {
        name: 'agentpool'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        osDiskSizeGB: 60
        count: 1
        minCount: 1
        maxCount: 3
        enableAutoScaling: true
        vmSize: 'Standard_B2ms'
        osType: 'Linux'
        osDiskType: 'Managed'
        vnetSubnetID: subnetId
        tags: tags
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: wks.id
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
    }
  }
}

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: '${stackName}-apim'
  location: location
  tags: tags
  sku: {
    capacity: 1
    name: 'Developer'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    virtualNetworkConfiguration: {
      subnetResourceId: subnetAPIMId
    }
    virtualNetworkType: 'External'
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource rewardsapi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: apim
  name: 'rewards-api'
  properties: {
    subscriptionRequired: true
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    apiRevision: '1'
    isCurrent: true
    displayName: 'Rewards API'
    path: 'rewards'
    protocols: [
      'http'
      'https'
    ]
  }


}
var rawValueapi = replace(replace(loadTextContent('apimjwtvalidation.xml'), '%jwtconfigappid%', jwtConfigAppId), '%jwtconfigtenantid%', jwtConfigTenantId)
resource rewardpolicy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: 'policy'
  parent: rewardsapi
  properties: {
    format: 'rawxml'
    value: rawValueapi
  }
}

resource rewardsapioperations 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: rewardsapi
  name:'rewards-api-operations'
  properties: {
    templateParameters: [
      {
        name: 'memberId'
        description: 'Member Id'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: 'Use this operation to lookup rewards points.'
    displayName: 'Lookup reward points'
    method: 'GET'
    urlTemplate: 'api/Points/member/{memberId}'
  }
}

resource rewardsapioperationspost 'Microsoft.ApiManagement/service/apis/operations@2021-08-01' = {
  parent: rewardsapi
  name:'rewards-api-operations-post'
  properties: {
    description: 'Use this operation to add rewards points.'
    displayName: 'Add reward points'
    method: 'POST'
    urlTemplate: 'api/Points/'
  }
}

// resource rewardsapipostschema 'Microsoft.ApiManagement/service/schemas@2021-08-01' = {
//   name: 'Payload'
//   parent: apim
//   properties: {
//     description: 'request payload expected format'
//     schemaType: 'json'
//     document: any(loadTextContent('Payload.json'))
//   }
// }

var rawValue = replace(loadTextContent('rewardsapi.xml'), '%urlapi%', urlapi)
resource rewardpointsget 'Microsoft.ApiManagement/service/apis/operations/policies@2021-04-01-preview' = {
  parent: rewardsapioperations
  name: 'policy'
  properties: {
    value: rawValue
    format: 'rawxml'
  }
}

var rawValue2 = replace(replace(loadTextContent('rewardsapipost.xml'), '%urlapi%', urlapi), '%jsonformat%', 'Payload')
resource rewardpointspost 'Microsoft.ApiManagement/service/apis/operations/policies@2021-04-01-preview' = {
  parent: rewardsapioperationspost
  name: 'policy'
  properties: {
    value: rawValue2
    format: 'rawxml'
  }
}

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: '${stackName}-ADF'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksMSIId}': {}
    }
  }
}


output aksName string = aks.name
output sqlserver string = sql.outputs.sqlFqdn
output sqlusername string = sqlUsername
output dbname string = sql.outputs.dbName
output tenantId string = subscription().tenantId
output managedIdentityId string = aks.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.clientId

var backendapp = '${stackName}backendapp'
resource backendappStr 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: backendapp
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: subnetId
          action: 'Allow'
        }
      ]
    }
  }
  tags: tags
}

output queueName string = queueName
output backendappStorageName string = backendappStr.name
output backend string = backendapp
output aadinstance string = environment().authentication.loginEndpoint
output stackname string = stackName
