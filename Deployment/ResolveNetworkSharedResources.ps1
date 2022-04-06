$groups = az group list --tag stack-environment=dev | ConvertFrom-Json
$networkingResourceGroup = ($groups | Where-Object { $_.tags.'stack-name' -eq 'platform' -and $_.tags.'stack-environment' -eq 'dev' -and $_.tags.'stack-sub-name' -eq 'networking' }).name
Write-Host "::set-output name=resourceGroup::$networkingResourceGroup"