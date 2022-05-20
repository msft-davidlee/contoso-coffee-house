param(     
    [Parameter(Mandatory = $true)][string]$AKSMSIId,
    [Parameter(Mandatory = $true)][string]$KeyVaultName,     
    [Parameter(Mandatory = $true)][string]$QueueName,
    [Parameter(Mandatory = $true)][string]$DOMAINNAME)


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
$ErrorActionPreference = "Stop"

# Prerequsites: 
# * We have already assigned the managed identity with a role in Container Registry with AcrPull role.
# * We also need to determine if the environment is created properly with the right Azure resources.
$all = GetResource -stackName cch-aks -stackEnvironment dev
$aks = $all | Where-Object { $_.type -eq 'Microsoft.ContainerService/managedClusters' }
$AKS_RESOURCE_GROUP = $aks.resourceGroup
$AKS_NAME = $aks.name

$sb = $all | Where-Object { $_.type -eq 'Microsoft.ServiceBus/namespaces' }
$ServiceBusName = $sb.name

$sql = $all | Where-Object { $_.type -eq 'Microsoft.Sql/servers' }
$sqlSv = az sql server show --name $sql.name -g $sql.resourceGroup | ConvertFrom-Json
$SqlServer = $sqlSv.fullyQualifiedDomainName
$SqlUsername = $sqlSv.administratorLogin

$db = $all | Where-Object { $_.type -eq 'Microsoft.Sql/servers/databases' }
$dbNameParts = $db.name.Split('/')
$DbName = $dbNameParts[1]

$storage = $all | Where-Object { $_.type -eq 'Microsoft.Storage/storageAccounts' }
$BackendStorageName = $storage.name

$kv = GetResource -stackName cch-shared-key-vault -stackEnvironment dev
$kvName = $kv.name

$AAD_INSTANCE = (az keyvault secret show -n contoso-customer-service-aad-instance --vault-name $kvName --query value | ConvertFrom-Json)
$AAD_DOMAIN = (az keyvault secret show -n contoso-customer-service-aad-domain --vault-name $kvName --query value | ConvertFrom-Json)
$AAD_TENANT_ID = (az keyvault secret show -n contoso-customer-service-aad-tenant-id --vault-name $kvName --query value | ConvertFrom-Json)
$AAD_CLIENT_ID = (az keyvault secret show -n contoso-customer-service-aad-client-id --vault-name $kvName --query value | ConvertFrom-Json)
$AAD_CLIENT_SECRET = (az keyvault secret show -n contoso-customer-service-aad-client-secret --vault-name $kvName --query value | ConvertFrom-Json)
$AAD_AUDIENCE = (az keyvault secret show -n contoso-customer-service-aad-app-audience --vault-name $kvName --query value | ConvertFrom-Json)
$AAD_SCOPES = (az keyvault secret show -n contoso-customer-service-aad-scope --vault-name $kvName --query value | ConvertFrom-Json)
$acr = GetResource -stackName cch-shared-container-registry -stackEnvironment dev
$acrName = $acr.Name

$log = $all | Where-Object { $_.type -eq 'microsoft.insights/components' }
az extension add --name application-insights
$appInsightsKey = az monitor app-insights component show --app $log.name -g $log.resourceGroup --query "instrumentationKey" -o tsv
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable get app insights instrumentation key."
}

# The version here can be configurable so we can also pull dev specific packages.
$version = "v4.12"

# Step 2: Login to AKS.
az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_NAME

# Step 3: Create a namespace for your resources if it does not exist.
$namespace = "myapps"
$testNamespace = kubectl get namespace $namespace
if (!$testNamespace ) {
    kubectl create namespace $namespace
}
else {
    Write-Host "Skip creating frontend namespace as it already exist."
}

# Step 4: Setup an external ingress controller
$repoList = helm repo list --output json | ConvertFrom-Json
$foundHelmIngressRepo = ($repoList | Where-Object { $_.name -eq "ingress-nginx" }).Count -eq 1

# Step 4a: Add the ingress-nginx repository
if (!$foundHelmIngressRepo ) {
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
}
else {
    Write-Host "Skip adding ingress-nginx repo with helm as it already exist."
}

$foundHelmKedaCoreRepo = ($repoList | Where-Object { $_.name -eq "kedacore" }).Count -eq 1

# Step 4a: Add the ingress-nginx repository
if (!$foundHelmKedaCoreRepo) {
    helm repo add kedacore https://kedacore.github.io/charts
}
else {
    Write-Host "Skip adding kedacore repo with helm as it already exist."
}

helm repo update

# Step 4b.
$testSecret = (kubectl get secret aks-ingress-tls -o json -n $namespace)
if (!$testSecret) {

    $strs = GetResource -stackName cch-shared-storage -stackEnvironment dev
    $BuildAccountName = $strs.name

    az storage blob download-batch -d . -s certs --account-name $BuildAccountName
    kubectl create secret tls aks-ingress-tls `
        --namespace $namespace `
        --key .\demo.contoso.com.key `
        --cert .\demo.contoso.com.crt

    if ($LastExitCode -ne 0) {
        throw "An error has occured. Unable to set TLS for demo.contoso.com."
    }
}


$pipResource = GetResource -stackName cch-networking -stackEnvironment dev
foreach($p in $pipResource)`
{
    if($p.type -eq 'Microsoft.Network/publicIPAddresses')`
    {$piprg = $p} `
}
$pip = (az network public-ip show --ids $piprg.id | ConvertFrom-Json)
$ip = $pip.ipAddress    
$ipFqdn = "contosocoffeehouse"
$ipResGroup = $piprg.resourceGroup

Write-Host "Configure ingress with static IP: $ip $ipFqdn $ipResGroup"
    
# Step 4c. Install ingress controller
# See: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace $namespace `
    --set controller.replicaCount=2 `
    --set controller.metrics.enabled=true `
    --set-string controller.podAnnotations."prometheus\.io/scrape"="true" `
    --set-string controller.podAnnotations."prometheus\.io/port"="10254" `
    --set controller.service.loadBalancerIP=$ip `
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=$ipFqdn `
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$ipResGroup

helm install keda kedacore/keda -n $namespace

$content = Get-Content .\Deployment\external-ingress.yaml

# Note: Interestingly, we need to set namespace in the yaml file although we have setup the namespace here in apply.
$content = $content.Replace('$NAMESPACE', $namespace)
$content = $content.Replace('$DOMAINNAME', $DOMAINNAME)
Set-Content -Path ".\external-ingress.yaml" -Value $content
$rawOut = (kubectl apply -f .\external-ingress.yaml --namespace $namespace 2>&1)
if ($LastExitCode -ne 0) {
    $errorMsg = $rawOut -Join '`n'
    if ($errorMsg.Contains("failed calling webhook") -and $errorMsg.Contains("validate.nginx.ingress.kubernetes.io")) {
        Write-Host "Attempting to recover from 'failed calling webhook' error."

        # See: https://pet2cattle.com/2021/02/service-ingress-nginx-controller-admission-not-found
        kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
        kubectl apply -f .\external-ingress.yaml --namespace $namespace
        if ($LastExitCode -ne 0) {
            throw "An error has occured. Unable to deploy external ingress."
        }
    }
    else {
        throw "An error has occured. Unable to deploy external ingress."
    }    
}

# Step 5: Setup configuration for resources

$imageName = "contoso-demo-service-bus-shipping-func:$version"
$SenderQueueConnectionString = az servicebus namespace authorization-rule keys list --resource-group $AKS_RESOURCE_GROUP `
    --namespace-name $ServiceBusName --name Sender --query primaryConnectionString | ConvertFrom-Json    

if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable get service bus connection string."
}
$SenderQueueConnectionString = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($SenderQueueConnectionString))

$QueueConnectionString = az servicebus namespace authorization-rule keys list --resource-group $AKS_RESOURCE_GROUP `
    --namespace-name $ServiceBusName --name Listener --query primaryConnectionString | ConvertFrom-Json
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable get service bus listener connection string."
}
$ListenerQueueConnectionString = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($QueueConnectionString))

# Step: 5b: Configure Azure Key Vault
$content = Get-Content .\Deployment\azurekeyvault.yaml
$content = $content.Replace('$MANAGEDID', $AKSMSIId)
$content = $content.Replace('$KEYVAULTNAME', $KeyVaultName)

$TenantId = az account show --query "tenantId" -o tsv

$content = $content.Replace('$TENANTID', $TenantId)

Set-Content -Path ".\azurekeyvault.yaml" -Value $content
kubectl apply -f ".\azurekeyvault.yaml" --namespace $namespace

if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy azure key vault app."
}

# Step: 5c: Configure Prometheus
$content = Get-Content .\Deployment\prometheus\kustomization.yaml
$content = $content.Replace('$NAMESPACE', $namespace)
Set-Content -Path ".\Deployment\prometheus\kustomization.yaml" -Value $content

$content = Get-Content .\Deployment\prometheus\prometheus.yaml
$content = $content.Replace('$NAMESPACE', $namespace)
Set-Content -Path ".\Deployment\prometheus\prometheus.yaml" -Value $content

kubectl apply --kustomize Deployment/prometheus -n $namespace
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to apply prometheus directory."
}

# Step 6: Deploy customer service app.
$backendKey = (az storage account keys list -g $AKS_RESOURCE_GROUP -n $BackendStorageName | ConvertFrom-Json)[0].value
$backendConn = "DefaultEndpointsProtocol=https;AccountName=$BackendStorageName;AccountKey=$backendKey;EndpointSuffix=core.windows.net"

$content = Get-Content .\Deployment\backendservice.yaml
$content = $content.Replace('$IMAGE', $imageName)
$content = $content.Replace('$DBSOURCE', $SqlServer)
$content = $content.Replace('$DBNAME', $DbName)
$content = $content.Replace('$DBUSERID', $SqlUsername)
$content = $content.Replace('$ACRNAME', $acrName)
$content = $content.Replace('$AZURE_STORAGE_CONNECTION', $backendConn)
$content = $content.Replace('$AZURE_STORAGEQUEUE_CONNECTION', $QueueConnectionString)
$content = $content.Replace('$QUEUENAME', $QueueName)
$content = $content.Replace('$APPINSIGHTSKEY', $appInsightsKey)

Set-Content -Path ".\backendservice.yaml" -Value $content
kubectl apply -f ".\backendservice.yaml" --namespace $namespace
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy backend service app."
}

# Step 7: Deploy customer service app.
$content = Get-Content .\Deployment\customerservice.yaml
$content = $content.Replace('$DBSOURCE', $SqlServer)
$content = $content.Replace('$DBNAME', $DbName)
$content = $content.Replace('$DBUSERID', $SqlUsername)
$content = $content.Replace('$ACRNAME', $acrName)
$content = $content.Replace('$NAMESPACE', $namespace)

$content = $content.Replace('$AADINSTANCE', $AAD_INSTANCE)
$content = $content.Replace('$AADTENANTID', $AAD_TENANT_ID)
$content = $content.Replace('$AADDOMAIN', $AAD_DOMAIN)
$content = $content.Replace('$AADCLIENTID', $AAD_CLIENT_ID)
$content = $content.Replace('$AADCLIENTSECRET', $AAD_CLIENT_SECRET)
$content = $content.Replace('$AADSCOPES', $AAD_SCOPES)
$content = $content.Replace('$APPINSIGHTSKEY', $appInsightsKey)
$content = $content.Replace('$VERSION', $version)

Set-Content -Path ".\customerservice.yaml" -Value $content
kubectl apply -f ".\customerservice.yaml" --namespace $namespace
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy customer service app."
}

# Step 8: Deploy Alternate Id service.
$content = Get-Content .\Deployment\alternateid.yaml
$content = $content.Replace('$DBSOURCE', $SqlServer)
$content = $content.Replace('$DBNAME', $DbName)
$content = $content.Replace('$DBUSERID', $SqlUsername)
$content = $content.Replace('$ACRNAME', $acrName)
$content = $content.Replace('$NAMESPACE', $namespace)

$content = $content.Replace('$AADINSTANCE', $AAD_INSTANCE)
$content = $content.Replace('$AADTENANTID', $AAD_TENANT_ID)
$content = $content.Replace('$AADDOMAIN', $AAD_DOMAIN)
$content = $content.Replace('$AADCLIENTID', $AAD_CLIENT_ID)
$content = $content.Replace('$AADAUDIENCE', $AAD_AUDIENCE)
$content = $content.Replace('$APPINSIGHTSKEY', $appInsightsKey)
$content = $content.Replace('$VERSION', $version)

Set-Content -Path ".\alternateid.yaml" -Value $content
kubectl apply -f ".\alternateid.yaml" --namespace $namespace

if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy alternate id app."
}

# Step 9: Deploy Partner api.
$content = Get-Content .\Deployment\partnerapi.yaml
$content = $content.Replace('$BASE64CONNECTIONSTRING', $SenderQueueConnectionString)
$content = $content.Replace('$ACRNAME', $acrName)
$content = $content.Replace('$NAMESPACE', $namespace)
$content = $content.Replace('$DBSOURCE', $SqlServer)
$content = $content.Replace('$DBNAME', $DbName)
$content = $content.Replace('$DBUSERID', $SqlUsername)
$content = $content.Replace('$SHIPPINGREPOSITORYTYPE', "ServiceBus")
$content = $content.Replace('$APPINSIGHTSKEY', $appInsightsKey)
$content = $content.Replace('$VERSION', $version)

Set-Content -Path ".\partnerapi.yaml" -Value $content
kubectl apply -f ".\partnerapi.yaml" --namespace $namespace

if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy partner api app."
}

# Step 10: Deploy Member service.
$content = Get-Content .\Deployment\memberservice.yaml
$content = $content.Replace('$DBSOURCE', $SqlServer)
$content = $content.Replace('$DBNAME', $DbName)
$content = $content.Replace('$DBUSERID', $SqlUsername)
$content = $content.Replace('$ACRNAME', $acrName)
$content = $content.Replace('$NAMESPACE', $namespace)

$content = $content.Replace('$AADINSTANCE', $AAD_INSTANCE)
$content = $content.Replace('$AADTENANTID', $AAD_TENANT_ID)
$content = $content.Replace('$AADDOMAIN', $AAD_DOMAIN)
$content = $content.Replace('$AADCLIENTID', $AAD_CLIENT_ID)
$content = $content.Replace('$AADAUDIENCE', $AAD_AUDIENCE)
$content = $content.Replace('$APPINSIGHTSKEY', $appInsightsKey)
$content = $content.Replace('$VERSION', $version)

Set-Content -Path ".\memberservice.yaml" -Value $content
kubectl apply -f ".\memberservice.yaml" --namespace $namespace
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy member service app."
}

# Step 10: Deploy Points service.
$content = Get-Content .\Deployment\pointsservice.yaml
$content = $content.Replace('$DBSOURCE', $SqlServer)
$content = $content.Replace('$DBNAME', $DbName)
$content = $content.Replace('$DBUSERID', $SqlUsername)
$content = $content.Replace('$ACRNAME', $acrName)
$content = $content.Replace('$NAMESPACE', $namespace)

$content = $content.Replace('$AADINSTANCE', $AAD_INSTANCE)
$content = $content.Replace('$AADTENANTID', $AAD_TENANT_ID)
$content = $content.Replace('$AADDOMAIN', $AAD_DOMAIN)
$content = $content.Replace('$AADCLIENTID', $AAD_CLIENT_ID)
$content = $content.Replace('$AADAUDIENCE', $AAD_AUDIENCE)
$content = $content.Replace('$APPINSIGHTSKEY', $appInsightsKey)
$content = $content.Replace('$VERSION', $version)

Set-Content -Path ".\pointsservice.yaml" -Value $content
kubectl apply -f ".\pointsservice.yaml" --namespace $namespace
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy points service app."
}

# Step 11: Function scaling based on specific scalers
$content = Get-Content .\Deployment\backendservicebus.yaml
$content = $content.Replace('$QUEUENAME', $QueueName)
$content = $content.Replace('$BASE64CONNECTIONSTRING', $ListenerQueueConnectionString)

Set-Content -Path ".\backendservicebus.yaml" -Value $content
kubectl apply -f ".\backendservicebus.yaml" --namespace $namespace
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to deploy service bus keda scaler."
}

# Step 12: Output ip address
$serviceip = kubectl get ing demo-ingress -n $namespace -o jsonpath='{.status.loadBalancer.ingress[*].ip}'
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to get IP. Check to see if it is ready."
}


if (!$serviceip){
    throw "No service ip found. Check to see if it is ready."
}
Write-Host "::set-output name=serviceip::$serviceip"