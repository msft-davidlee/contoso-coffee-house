param(
    [Parameter(Mandatory = $true)][string]$DbName,
    [Parameter(Mandatory = $true)][string]$SqlServer,
    [Parameter(Mandatory = $true)][string]$SqlUsername)

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

$kv = GetResource -stackName cch-shared-key-vault -stackEnvironment dev
$kvName = $kv.name

$sqlPassword = (az keyvault secret show -n contoso-customer-service-sql-password --vault-name $kvName --query value | ConvertFrom-Json)
$sqlConnectionString = "Server=$SqlServer;Initial Catalog=$DbName; User Id=$SqlUsername;Password=$sqlPassword"
Write-Host "::set-output name=sqlConnectionString::$sqlConnectionString"