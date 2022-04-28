[Main](README.md)

# Introduction
Azure Blueprint allows the Contoso IT team to create the necessary guardrails for their Development team to be successful. 

# Requirements
1. All resources must be located in specific regions in US
2. The Contoso IT team would like to follow the least privilege principle. Developers should only be allowed access to specific resource groups. For example, there is a resource group for shared resources such as Azure Key Vault. The service principal used for deployment should only have read access to secrets but the developers should have both read/write access to secrets. 

# Setup
Please follow the steps below to deploy the Azure Blueprint into your Azure Subscription. Note that you will either need to use CloudShell or ensure Azure CLI is installed locally.

1. [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this git repo locally.
2. Next, we will execute a blueprint deployment to create our environment which consists of shared resources, networking and application resource groups and take care of RBAC. The first step is to create a Service Principal which is assigned into each resource group. Take note of the tenant Id, appId and password.
```
az ad sp create-for-rbac -n "Contoso Coffee House GitHub"
```
![Create Service Principal](/doc/CreateServicePrincipal.png)
3. We need to get the Object Id for the Service principal we have created. This is used as input to our Blueprint deployment later.
```
az ad sp show --id <appId from the previous command> --query "objectId" | ConvertFrom-Json
```
![Get Service Principal Object Id](/doc/GetServicePrincipalObjectId.png)
4. We need to get the Object Id for our user. This is used as input to our Blueprint deployment later so we can grant oursleves access to shared resources such as Azure Key Vault.
```
az ad signed-in-user show --query 'objectId' | ConvertFrom-Json
```
![Get Signed In User Object Id](/doc/GetSignedInUserObjectId.png)
5. [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this git repo locally.
6. We should cd into the blueprint directory and execute our blueprint.bicep with the following command.
```
DeployBlueprint.ps1 -SVC_PRINCIPAL_ID <Object Id for Contoso Coffee House GitHub Service Principal> -MY_PRINCIPAL_ID <Object Id for your user>
```
8. Create the secret(s) in your github dev environment as defined in secrets section below. Be sure to populate with your desired values from the previous steps. 
9. Create certificate for your solution using the following ``` openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out demo.contoso.com.crt -keyout demo.contoso.com.key -subj "/CN=demo.contoso.com/O=aks-ingress-tls" ```
10. Next, upload the outputs to a container named certs in your shared storage account.

## Secrets
| Name | Value |
| --- | --- |
| CCH_AZURE_CREDENTIALS | <pre>{<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientSecret": "", <br/>&nbsp;&nbsp;&nbsp;&nbsp;"subscriptionId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"tenantId": "" <br/>}</pre> |
| PREFIX | mytodos - or whatever name you would like for all your resources |
| SOURCE_IP | This is your home or office IP. This is applied on NSG to allow you to access your web app |