$ErrorActionPreference = "Stop"

$BUILD_ENV = 'dev'

$groups = az group list --tag stack-environment=$BUILD_ENV | ConvertFrom-Json
$resourceGroupName = ($groups | Where-Object { $_.tags.'stack-name' -eq 'cch-aks' -and $_.tags.'stack-environment' -eq $BUILD_ENV -and !($_.name.StartsWith("databricks")) -and !($_.tags.'aks-managed-cluster-name') }).name
$aks = (az resource list -g $resourceGroupName --resource-type "Microsoft.ContainerService/managedClusters" | ConvertFrom-Json)[0]
az aks get-credentials -n $aks.name -g $resourceGroupName --overwrite-existing
$acr = (az resource list --tag stack-name='cch-shared-container-registry' | ConvertFrom-Json)[0]
$acrName = $acr.name
az aks update -n $aks.name -g $resourceGroupName --attach-acr $acrName
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to update aks with acr."
}

$aksName = $aks.name
$objectId = (az aks show -g $resourceGroupName -n $aksName --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId -o tsv)
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to get object Id for performing role assignment."
}

$resId = (az group show --name $acr.resourceGroup | ConvertFrom-Json).id
az role assignment create --assignee $objectId --role "Key Vault Secrets User" --scope $resId
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to perform Key Vault Secrets User role asignment for aks."
}

az aks check-acr -n $aksName -g $resourceGroupName --acr "$acrName.azurecr.io"
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to verify if aks and acr are connected."
}

kubectl get services -n myapps
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to list all services"
}