# Disclaimer
The information contained in this README.md file and any accompanying materials (including, but not limited to, scripts, sample codes, etc.) are provided "AS-IS" and "WITH ALL FAULTS." Any estimated pricing information is provided solely for demonstration purposes and does not represent final pricing and Microsoft assumes no liability arising from your use of the information. Microsoft makes NO GUARANTEES OR WARRANTIES OF ANY KIND, WHETHER EXPRESSED OR IMPLIED, in providing this information, including any pricing information.

# Introduction 
This project show cases several solutions for a fictional company called Contoso Coffee House or CCH for short. CCH has been in business for over 15 years and has grown from a few stores in the Dallas Fort Worth area to entire US and Canada (North America).

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
1. The solutions needs to be avaliable for over 1000 stores located in North America (US and Canada).
2. The solutions needs to be avaliable during store operation hours which is between 5 AM to 11:00 PM CST.
3. The solutions needs to have an SLA of 99.9% uptime.

### New Business Requirements
* Contoso Coffee House would like to craft promotions based on analytics related to purchases. For example, buying a specific product SKU would have the effect of doubling the points. There is nothing in place today for that.
* Contoso Coffee House would like to consider real-time award of points to increase member satisfaction with the program and perhaps additional purchases because of potential to get more points. One thought is that the Point-Of-Sale could forward transaction. There could potentially be a daily transaction log generated for reconciliation.
* Customers can exchange items directly from their mobile apps.
* Would like to at some point collobrate with other organizations with similar loyalty program so points can be award from them either real-time or maybe based on schedule from their transaction logs. Offers can be displayed and customer can choose to opt-in via their Mobile App. For example, if the customer uses a Credit Card from a certain bank to make the purchase, there would be double points awarded. This would be a beta program.
* Security MUST be a priority and we should design with zero trust in mind.

# Demos
The following are required to be executed as prerequisites for the solutions. This means that minimally you can also show case Azure Governance and DevOps practices by default along with the solutions.

1. [Get started](GETSTARTED.md)
2. [Governance with Azure Blueprint](AZUREBLUEPRINTS.md)
3. [DevOps with GitHub Actions](DEVOPS.md)

## Solutions
The following are solutions developed to meet the new business requirements.

1. [Internal Web App with backend job processing (Frontdoor, AKS, SQL, Functions, Service Bus and AAD)](AKS.md)
1. [Realtime Data Ingestion with API Microservices (Frontdoor, AKS, SQL, APIM and AAD)](AKS.md)
2. [ETL Batch File Processing (Storage, DataFactory, SQL, AKS, APIM and AAD)](DATAFACTORY.md)

Optionally, we also have [Local .NET development with Docker](LOCALDEV.md) that speaks to how a developer can think about local development practices. The .NET solution in this project are developed with this practice.

## Have an issue?
You are welcome to create an issue if you need help but please note that there is no timeline to answer or resolve any issues you have with the contents of this project. Use the contents of this project at your own risk! If you are interested to volunteer to maintain this, please feel free to reach out to be added as a contributor and send Pull Requests (PR).