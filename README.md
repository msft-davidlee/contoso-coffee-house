# Disclaimer
The information contained in this README.md file and any accompanying materials (including, but not limited to, scripts, sample codes, etc.) are provided "AS-IS" and "WITH ALL FAULTS." Any estimated pricing information is provided solely for demonstration purposes and does not represent final pricing and Microsoft assumes no liability arising from your use of the information. Microsoft makes NO GUARANTEES OR WARRANTIES OF ANY KIND, WHETHER EXPRESSED OR IMPLIED, in providing this information, including any pricing information.

# Introduction 
This project show cases a solution for Contoso Coffee House which has been in business for over 15 years and has grown from a few stores in the Dallas Fort Worth area to entire US and Canada (North America).

## Background
Contoso Coffee House started a Loyalty Program about 10 years ago where every $1 purchase would earn 1 point. This program helped them grow their customer base. Currently there are about 3 million members and expect to double in the next 3 years. More about the Loyalty Program:

* Customers sign up for free.
* Customers can exchange for items in Store with help from Barista which means manual work via a Customer Service webapp to lookup member and select the exchange item. The Customer service web app is already using Azure Active Directory for signing in employees. For some items, a Partner will be handling the order and ship item to the member. Partner will manage the inventory so if an item is not available, the system will notify immediately.
* Customer can order in store today and get points awarded within 7 days. This is because the full Transaction Log from each store is pushed in weekly usually on the weekend and a backend system would award points so it can be used.

### How customers order today
* Customers can order directly from Barista who operate a POS cashier
* Customers can make an order by Mobile Apps which is developed about 3 years ago. This accounts for about 50% of members.
* Customers can also make an order from website, although this is less than 1%.

## Requirements
1. The solution needs to be avaliable for over 1000 stores located in North America (US and Canada).
2. The solution needs to be avaliable during store operation hours which is between 6 AM to 11:00 PM CST.
3. The solution needs to have an SLA of 99.9% uptime.

### New Business Requirements
* Contoso Coffee House would like to craft promotions based on analytics related to purchases. For example, buying more than $50 would have the effect of doubling the points. Nothing in place today for that.
* Contoso Coffee House would like to consider real-time award of points to increase member satisfaction with the program and perhaps additional purchases because of potential to get more points. One thought is that the Point-Of-Sale could forward transaction. There could potentially be a daily transaction log generated for reconciliation.
* Customers can exchange items directly from their mobile apps.
* Would like to at some point collobrate with other organizations with similar loyalty program so points can be award from them either real-time or maybe based on schedule from their transaction logs. Offers can be displayed and customer can choose to opt-in via their Mobile App. For example, if the customer uses a Credit Card from a certain bank to make the purchase, there would be double points awarded. This would be a beta program.
* Security MUST be a priority so the system cannot be hacked.

## Architecture
1. The solution has a frontend component that requires login from the Customer Service Rep.
2. The solution has an API service that will allow users to lookup members and consume rewards.
3. When the Program changed, all members were assigned a new Member Id. However, not all members have transitioned to the new Program and may be using their old card. Hence, there is a Alternate Id Service that allows Customer Service Rep to search for the member using the old member Id. There will be a grace period and Contoso would like to retire the old member Id in 3 years.
4. Contoso IT has an agreement with the Partner IT to communicate requests via an Enterprise Service Bus (ESB) of their choosing. The Partner development team will subscribe request from the ESB.
5. In order to monitor the health of the system and ensure the SLA is met, there will be Application Monitoring created throughout the system.

![Architecture](/Architecture/Solution.png)

# Demo
We will host this solution in Azure Kubernetes Service (AKS)

The technology stack used includes .NET 6, MS SSQL, Azure Service Bus, and Azure Functions for processing backend requests. Most services can be run and debugged locally via emulators except for Azure Service Bus.

## Use this Project to showcase solutions
1. This solution employs a microservice architecture where we have the API and legacy API service in relation to the Member Id question. It may not make sense for the business to include the old Member Id as part of the new system as it will be retired in 3 years. As such, we are keeping the legacy API. Here, it may make sense to think about leveraging APIM so we have a consistent API experience for our microservice.
2. The Enterprise Service Bus approach is an interesting way for Contoso to "expose" their request to a third party because this is typically done by making a call to the third party endpoint. However, not all third party vendors will host their applications as services on the internet as their core business is not in technology but in fulfillment. Hence, the ESB approach will allow the most flexibility for any third party vendors. For example, if a vendor already has an API endpoint, they can simply create a proxy app to subscribe and push the request to their API. If they don't, they will create an app to subscribe to the ESB and consume the fulfillment request.
3. The security of the web app is taken care of using Identity Providers rather than a custom authentication approach (think asp.net forms authentication where we end up creating our own identity store in the olden days). A third party approach like AAD B2B or B2C means Contoso can get developers to focus on business problems and leave authentication and authorization to the experts.

# Local Development
If you are interested to run this Solution locally as a Developer, you will need to make sure you have the Azurite emulator, and a local instance of SQL Server running. I recommand installing Docker Desktop so you can install these dependencies which is the easist way to get started. Once you have configured Docker Desktop, you can run the following which uses Docker to install Storage and SQL dependencies.

```
.\LocalEnv\Install.ps1 -Password <Password>
```

# Get Started
Please follow the steps below to deploy this solution into your Azure Subscription. Note that you will either need to use CloudShell or ensure Azure CLI is installed locally.

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
6. Create the secret(s) in your github dev environment as defined in secrets section below. Be sure to populate with your desired values from the previous steps. 
7. Create a branch named demo or dev and push into your git remote repo to kick off the CI process because it is tied to the name of the git branch.
8. Create certificate for your solution using the following ``` openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out demo.contoso.com.crt -keyout demo.contoso.com.key -subj "/CN=demo.contoso.com/O=aks-ingress-tls" ```
9. Next, upload the outputs to a container named certs in your shared storage account.
10. You will need to run the CompleteSetup.ps1 script manually in CloudShell or your local Azure CLI.
11. To check if everything is setup successfully, review the script output for any errors.
12. Update your local host file to point to the public ip.

## Secrets
| Name | Value |
| --- | --- |
| CCH_AZURE_CREDENTIALS | <pre>{<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientSecret": "", <br/>&nbsp;&nbsp;&nbsp;&nbsp;"subscriptionId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"tenantId": "" <br/>}</pre> |
| PREFIX | mytodos - or whatever name you would like for all your resources |
| SOURCE_IP | This is your home or office IP. This is applied on NSG to allow you to access your web app |

## Have an issue?
You are welcome to create an issue if you need help but please note that there is no timeline to answer or resolve any issues you have with the contents of this project. Use the contents of this project at your own risk! If you are interested to volunteer to maintain this, please feel free to reach out to be added as a contributor and send Pull Requests (PR).