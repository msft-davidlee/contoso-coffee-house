param(
    [string]$Prefix)

function GetResource([string]$stackName, [string]$stackEnvironment) {
    $platformRes = (az resource list --tag stack-name=$stackName | ConvertFrom-Json)
    if (!$platformRes) {
        throw "Unable to find eligible $stackName resource!"
    }
    if ($platformRes.Length -eq 0) {
        throw "Unable to find 'ANY' eligible $stackName resource!"
    }
    
    $res = ($platformRes | Where-Object { $_.tags.'stack-environment' -eq $stackEnvironment })
    if (!$res) {
        throw "Unable to find resource by environment!"
    }
    
    return $res
}

$allResources = GetResource -stackName cch-networking -stackEnvironment dev
$vnet = $allResources | Where-Object { $_.type -eq 'Microsoft.Network/virtualNetworks' -and (!$_.name.EndsWith('-nsg')) -and $_.name.Contains('-pri-') }
$vnetRg = $vnet.resourceGroup
$vnetName = $vnet.name
$location = $vnet.location
Write-Host "::set-output name=location::$location"
Write-Host "::set-output name=networkResourceGroup::$vnetRg"

$subnets = (az network vnet subnet list -g $vnetRg --vnet-name $vnetName | ConvertFrom-Json)
if (!$subnets) {
    throw "Unable to find eligible Subnets from Virtual Network $vnetName!"
}          
$subnetId = ($subnets | Where-Object { $_.name -eq "aks" }).id
if (!$subnetId) {
    throw "Unable to find Subnet resource!"
}
Write-Host "::set-output name=subnetId::$subnetId"


$kv = GetResource -stackName cch-shared-key-vault -stackEnvironment dev
$kvName = $kv.name
Write-Host "::set-output name=keyVaultName::$kvName"
$sharedResourceGroup = $kv.resourceGroup
Write-Host "::set-output name=sharedResourceGroup::$sharedResourceGroup"

# This is the rg where the application should be deployed
$groups = az group list --tag stack-environment=dev | ConvertFrom-Json
$appResourceGroup = ($groups | Where-Object { $_.tags.'stack-name' -eq 'cch-aks' }).name
Write-Host "::set-output name=appResourceGroup::$appResourceGroup"

# We can provide a name but it cannot be existing
# https://docs.microsoft.com/en-us/azure/aks/faq#can-i-provide-my-own-name-for-the-aks-node-resource-group
$nodesResourceGroup = "$appResourceGroup-$Prefix"
Write-Host "::set-output name=nodesResourceGroup::$nodesResourceGroup"

# https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-use-key-vault
$keyVaultId = $kv.id
Write-Host "::set-output name=keyVaultId::$keyVaultId"

# Also resolve managed identity to use
$identity = az identity list -g $appResourceGroup | ConvertFrom-Json
$mid = $identity.id
Write-Host "::set-output name=managedIdentityId::$mid"