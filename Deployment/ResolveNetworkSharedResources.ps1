$groups = az group list --tag stack-environment=dev | ConvertFrom-Json
$networkingResourceGroup = ($groups | Where-Object { $_.tags.'stack-name' -eq 'cch-platform' -and $_.tags.'stack-environment' -eq 'dev' -and $_.tags.'stack-sub-name' -eq 'cch-networking' }).name
Write-Host "::set-output name=resourceGroup::$networkingResourceGroup"
$Vnets = az network vnet list -g $networkingResourceGroup | ConvertFrom-Json
$priVnetId = ($Vnets | Where-Object {$_.name -eq "cch-platform-centralus-pri-vnet" }).id
Write-Host "::set-output name=priVnetId::$priVnetId"