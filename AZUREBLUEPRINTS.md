[Main](README.md)

# Introduction
Azure Blueprint allows the Contoso IT team to create the necessary guardrails for their Development team to be successful. The Contoso IT team would like to follow the least privilege principle. 

# Requirements
1. All resources must be located in specific regions in US
2. Developers should only be allowed access to specific resource groups. For example, there is a resource group for shared resources such as Azure Key Vault. The service principal used for deployment should only have read access to secrets but the developers should have both read/write access to secrets.

# Implementation
We can following the instructions below for running this particular demo.

1. We need to execute a blueprint deployment to create our environment, shared resources and take care of RBAC. The first step is to create a Service Principal which is assigned into each resource group. Take note of the tenant Id, appId and password.
```
az ad sp create-for-rbac -n "Contoso Coffee House GitHub"
```
![Create Service Principal](/doc/CreateServicePrincipal.png)
2. We need to get the Object Id for the Service principal we have created. This is used as input to our Blueprint deployment later.
```
az ad sp show --id <appId from the previous command> --query "objectId" | ConvertFrom-Json
```
![Get Service Principal Object Id](/doc/GetServicePrincipalObjectId.png)
3. We need to get the Object Id for our user. This is used as input to our Blueprint deployment later so we can grant oursleves access to shared resources such as Azure Key Vault.
```
az ad signed-in-user show --query 'objectId' | ConvertFrom-Json
```
![Get Signed In User Object Id](/doc/GetSignedInUserObjectId.png)
4. [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this git repo locally.
5. We should cd into the blueprint directory and execute our blueprint.bicep with the following command.
```
DeployBlueprint.ps1 -SVC_PRINCIPAL_ID <Object Id for Contoso Coffee House GitHub Service Principal> -MY_PRINCIPAL_ID <Object Id for your user>
```
