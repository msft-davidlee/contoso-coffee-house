# Disclaimer
The information contained in this README.md file and any accompanying materials (including, but not limited to, scripts, sample codes, etc.) are provided "AS-IS" and "WITH ALL FAULTS." Any estimated pricing information is provided solely for demonstration purposes and does not represent final pricing and Microsoft assumes no liability arising from your use of the information. Microsoft makes NO GUARANTEES OR WARRANTIES OF ANY KIND, WHETHER EXPRESSED OR IMPLIED, in providing this information, including any pricing information.

# Introduction 
This project show cases several solutions for a fictitious company called Contoso Coffee House or CCH for short. CCH has been in business for over 15 years and has grown from a few stores in the Dallas to entire US and Canada (North America).

## Background
CCH started a Loyalty Program about 10 years ago where every $1 purchase would earn 1 point. This program helped them grow their customer base. Currently there are about 3 million members and expect to double in the next 3 years. More about the Loyalty Program:

* Customers sign up for free.
* Customers can exchange for items in Store with help from Barista which means manual work via a Customer Service webapp to lookup member and select the exchange item. The Customer service web app is already using Azure Active Directory for signing in employees. For some items, a Partner will be handling the order and ship item to the member. Partner will manage the inventory so if an item is not available, the system will notify immediately.
* Customer can order in store today and get points awarded within 7 days. This is because the full Transaction Log from each store is pushed in weekly usually on the weekend and a on-premise backend system with limitations in capacity would award points so it can be used.
* The solutions needs to be avaliable for over 1000 stores located in North America (US and Canada).
* The solutions needs to be avaliable during store operation hours which is between 5 AM to 11:00 PM CST.

### How customers order today
* Customers can order directly from Barista who operate a POS terminal.
* Customers can make an order by Mobile Apps which is developed about 3 years ago. This accounts for about 50% of members.
* Customers can also make an order from website, although this is less than 1%.

### New Business Requirements
* Contoso Coffee House would like to consider real-time award of points to increase member satisfaction with the program and perhaps additional purchases because of potential to get more points. One thought is that the Point-Of-Sale could forward transaction. If there's an issue with internet connectivity in the store or a region, there needs to be a catch up process that can scale to meet any processing demands.
* Would like to at some point collobrate with other organizations with similar loyalty program so points can be award from them either real-time or maybe based on schedule from their transaction logs. For example, if the customer buys a particular item from a vendor with a specific SKU, there could be double points awarded.
* Security MUST be a priority and we should design with zero trust in mind.

# Demo Environment
The following are solutions created as part of the demo. The first solution represents the existing solution in place today while the second and third solution are designed to meet the new business requirements. 

1. [Customer Service Web App with a backend points-for-rewards jobs processing (Frontdoor, AKS, SQL, Functions, Service Bus and AAD)](APP.md)
2. [Real-time API Data Ingestion to award points API Microservice (Frontdoor, AKS, SQL, APIM and AAD)](AKS.md)
3. [Batch Ingestion of Transaction Log File sent to API Microservice (Frontdoor, AKS, SQL, APIM, AAD and Databricks)](BATCHPROCESSING.md)

# Setting up the Demo Environment
Follow the steps below to create the demo environment in your own Azure Subscription. Be sure to review prerequisites first!

## Prerequisites
1. Azure Subscription:
    * Owner Access to the Subscription where the solution will be running in.
    * Access to create App registrations in Azure Active Directory (AAD) which is associated with that Azure Subscription.
    * For [Solution 1, Customer Service Web App](APP.md), you will also need to access to a different Azure Active Directory for hosting CCH users i.e. the Customer Service Reps. to login from.
2. Azure CLI installed locally or Azure CloudShell configurd in your Azure Subscription.
3. A GitHub account as we are planning to use GitHub Actions to drive CI/CD with it.

## Steps
1. As an Azure Subscription Owner/ Administrator, we will need to establish a landing zone as well as AAD setup with the following step: [Governance with Azure Blueprint](AZUREBLUEPRINTS.md)
2. Next, the Development team will be responsible for writing the code. As a quick note, this step is **OPTIONAL**! For this part, We can optionally review [Local .NET development](LOCALDEV.md) which speaks to how *you*, as a developer can setup local development for the .NET solution. As an example, you can make a code change and see the CI/CD run from start to end.
3. Lastly, the DevOps engineer working closely with the Development team will develop the infrastrure-as-code (IaC) practices and we can follow the steps mentioned in: [DevOps (CI/CD) with GitHub Actions](DEVOPS.md).
4. With that, the demo environment with the solutions will be created. Note that there is potentially specific setup with each solution. Please review the specific solutions you are interested to demo/review to perform them as mentioned by the above step.

# Cost Optimization
The biggest cost for the solutions would be related to API calls coming in from POS Terminals given that would generate the load. Hence, we should consider the following for cost optimizations depending on the load. The customer service app is going to be predictable based on a relative fixed number of users.

1. Picking the [right VM Size](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes) for the expected load
2. Autoscale configuration of the min and max nodes via [Cluster autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler)
3. Log Analytics Workspace usage and cost as we monitor the microservices as there might be unexpected based on large amount of log data due to API usage.

## Have an issue?
You are welcome to create an issue if you need help but please note that there is no timeline to answer or resolve any issues you have with the contents of this project. Use the contents of this project at your own risk! If you are interested to volunteer to maintain this, please feel free to reach out to be added as a contributor and send Pull Requests (PR).
