[Main](README.md) | [Internal Customer Service Web App](APP.md) | [Real-time API Data Ingestion](AKS.md) | [ETL Batch Transaction File processing](DATAFACTORY.md)

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
7. Create certificate for your solution using the following ``` openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out demo.contoso.com.crt -keyout demo.contoso.com.key -subj "/CN=demo.contoso.com/O=aks-ingress-tls" ```
8. Next, upload the outputs to a container named certs in your shared storage account.
9. We will need to create an App Registration to represent your API. I recommand creating a different AAD tenant instead of using your CORP AAD tenant to avoid permission/setup issues. If you have a VS Subscription, you probably already associate that with your own AAD tenant which would be a good one to use. You should also note that as part of Azure Blueprint deployment, you have an existing Azure Key Vault created which you need to use in a moment. For now, use the following:
    1. Name: **Contoso Customer Service Rewards API**
    2. Under *Expose an API*, create the following Application ID URI: **api://contoso-cs-rewards-api** and create the following scope: **Points.List**
    3. Under *App roles*, create the following App roles **Access API**
    4. Save Client Id in the Azure Key Vault with key as **contoso-customer-service-aad-app-client-id**
    5. Save the following value *api://contoso-cs-rewards-api/.default* with key as **contoso-customer-service-aad-scope** in Azure Key Vault.
    6. Save the tenant Id of AAD with key as **contoso-customer-service-aad-tenant-id** in Azure Key Vault.
    7. Save the audience value of *api://contoso-cs-rewards-api* with key as **contoso-customer-service-aad-app-audience** in Azure Key Vault.
    8. Save the AAD Domain name with value of *YOURDOMAIN.onmicrosoft.com* with key as **contoso-customer-service-aad-domain**. Remember to replace YOURDOMAIN with your actual instance name!
    9. Save the Instance URI with value of *https://login.microsoftonline.com/* with key as **contoso-customer-service-aad-instance**
10. We will need to create an App Registration to represent your API Client such as for Postman during testing and other service-to-service communications. 
    1. Name: **Contoso Customer Service Rewards API Client**
    2. Save Client Id in the Azure Key Vault with key as **contoso-customer-service-aad-postman-client-id**
    3. Under *Certificates & secrets*, create a client secret and save it in the Azure Key Vault with key as **contoso-customer-service-aad-postman-client-secret**
    4. Under *API permissions*, we will add **Contoso Customer Service Rewards API** and grant admin constent. Next, we will do the same for **Access API**.
11. We will need to create an App Registration to represent your Web App. Use the following: 
    1. Name: **Contoso Customer Service Rewards Web**
    2. Authentication: Web
    3. Under Redirect URIs: Add https://demo.contoso.com/signin-oidc
    4. Under *Select the tokens you would like to be issued by the authorization endpoint:*, choose **ID tokens**
    5. Under *Who can use this application or access this API?*, choose **Accounts in this organizational directory only... Single tenant)**
    6. Save Client Id in the Azure Key Vault with key as **contoso-customer-service-aad-client-id**
    7. Under *API permissions*, we will add **Contoso Customer Service Rewards API** and grant admin constent.
    8. Under App roles, we will add 2 roles **Contoso Customer Service Supervisor** with value of **CS.Supervisor** and **Contoso Customer Service Agent** with value of **CS.Agent**. It is important to get the value correct as the .NET Web App is actually going to leverage them as part of what permissions the user has.
12. Next, we should create a few test users. The goal here is we can assign users directly via Enterprise applications app roles or indirectly via Group assignments. As seen in the screenshot below, we can see the user *David Demo* assigned **Contoso Customer Service Supervisor**.
![Architecture](/doc/RoleAssignment.png)

## Next step
[Continue to Step 2 which is OPTIONAL](LOCALDEV.md) OR [Continue to Step 3](DEVOPS.md)