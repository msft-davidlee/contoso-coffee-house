$ErrorActionPreference = "Stop"

$platformRes = (az resource list --tag stack-name=cch-shared-container-registry | ConvertFrom-Json)
if (!$platformRes) {
    throw "Unable to find eligible platform container registry!"
}
if ($platformRes.Length -eq 0) {
    throw "Unable to find 'ANY' eligible platform container registry!"
}

$acr = ($platformRes | Where-Object { $_.tags.'stack-environment' -eq 'dev' })
if (!$acr) {
    throw "Unable to find eligible container registry!"
}
$AcrName = $acr.Name

# Login to ACR
az acr login --name $AcrName
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to login to acr."
}

$list = az acr repository list --name $AcrName | ConvertFrom-Json
if ($LastExitCode -ne 0) {
    throw "An error has occured. Unable to list from repository"
}

# Do not change this as this affect container reg
$namePrefix = "contoso-demo"
$apps = @(
    @{
        name = "$namePrefix-website";
        path = "DemoWebsite";
    },
    @{
        name = "$namePrefix-member-points-service";
        path = "DemoCustomerServicePoints";
    },    
    @{
        name = "$namePrefix-member-service";
        path = "DemoCustomerServiceMember";
    },
    @{
        name = "$namePrefix-alternate-id-service";
        path = "DemoCustomerServiceAltId";
    },
    @{
        name = "$namePrefix-partner-api";
        path = "DemoPartnerAPI";
    },
    @{
        name = "$namePrefix-service-bus-shipping-func";
        path = "DemoServiceBusShippingFunc";
    }
)

$version = "v4.7"
for ($i = 0; $i -lt $apps.Length; $i++) {
    $app = $apps[$i]

    $appName = $app.name
    $path = $app.path
    $appVersion = $version

    $imageName = "$appName`:$appVersion"

    $shouldBuild = $true
    $tags = az acr repository show-tags --name $AcrName --repository $appName | ConvertFrom-Json
    if ($tags) {
        if ($tags.Contains($appVersion)) {
            $shouldBuild = $false
        }
    }

    if ($shouldBuild -eq $true) {
        # Build your app with ACR build command
        az acr build --image $imageName -r $AcrName --file ./$path/Dockerfile .
    
        if ($LastExitCode -ne 0) {
            throw "An error has occured. Unable to build image."
        }
    }
}