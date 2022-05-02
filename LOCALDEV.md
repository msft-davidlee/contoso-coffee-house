[Main](README.md)

# Local .NET development
If you are interested to run this Solution locally as a Developer, you will need to make sure you configure Visual Studio start up with Multiple start up project option. See below on what to configure:

![Multi-solution startup](/doc/MultiSolutionStartup.png)

In your individual project, you can configure the right startup options for either Docker app as the host.

If you have Docker Desktop, you can install the following containers. You can manually install them using the links or use the PowerShell script provided. Note that the password refers to the SQL password.
* [Azurite emulator](https://hub.docker.com/_/microsoft-azure-storage-azurite)
* [SQL Server](https://hub.docker.com/_/microsoft-mssql-server)

```
.\LocalEnv\Install.ps1 -Password <Password>
```

You should see the following in Docker Desktop. If they are not running, please start them via the UI.

![Docker Desktop](/doc/DockerStartup.png)

If you do NOT have Docker Desktop, you need to manually install SQL Server and Azurite emulator.

## SQL Server
If you did not run the PowerShell script, you will need to configure the database. Login with SQL management Studio and run the following scripts

* Db\App.sql
* Db\Migrations.sql

## App Settings
You will need to configure the following local appsettings.json file for any of the non-web app services/Azure functions, i.e. DemoCustomerServiceAltId, DemoCustomerServiceMember and DemoPartnerAPI. You can get the Tenant Id, Client Id and domain as part of what you configured under [Governance with Azure Blueprint](AZUREBLUEPRINTS.md). Please check the port number for AlternateIdServiceUri or configure per docker local service reference to make sure it is correct. Usually this is configured under the project's launchSettings.json.

```
{
  "DbSource": "localhost",
  "DbName": "app",
  "DbUserId": "sa",
  "DbPassword": "<Password when installing your Local SQL>",
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "Domain": "<YOURTENANT>.onmicrosoft.com",
    "TenantId": "",
    "ClientId": "",
    "Audience": "api://contoso-cs-rewards-api"
  },
  "AlternateIdServiceUri": "https://localhost:44300/",
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

You will need to configure the following for DemoServiceBusShippingFunc. Esentially, you are missing just the password.

```
{
  "IsEncrypted": false,
  "Values": {
    "DbSource": "localhost",
    "DbName": "app",
    "DbUserId": "sa",
    "DbPassword": "",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "QueueName": "orders",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    "Connection": "UseDevelopmentStorage=true"
  }
}
```

Lastly, for the DemoWebsite, you will need to configure the following appsettings.json. You can get the AAD settings from the Azure Blueprint steps as mentioned earlier. Please check the port numbers on the Microservices or configure per docker local service reference. Usually this is configured under the project's launchSettings.json.

```
{
  "DbSource": "localhost",
  "DbName": "app",
  "DbUserId": "sa",
  "DbPassword": "",
  "EnableAuth": true,
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "TenantId": "",
    "Domain": "<YOURTENANT>.onmicrosoft.com",
    "ClientId": "",
    "ClientSecret": "",
    "CallbackPath": "/signin-oidc",
    "Scopes": "api://contoso-cs-rewards-api/.default"
  },
  "MemberServiceUri": "https://localhost:44335/",
  "AlternateIdServiceUri": "https://localhost:44300/",
  "PartnerAPIUri": "https://localhost:5005"
}
```