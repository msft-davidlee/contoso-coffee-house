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
* Contoso Coffee House would like to craft promotions based on analytics related to purchases. For example, buying a specific product SKU would have the effect of doubling the points. There is nothing in place today for that.
* Contoso Coffee House would like to consider real-time award of points to increase member satisfaction with the program and perhaps additional purchases because of potential to get more points. One thought is that the Point-Of-Sale could forward transaction. There could potentially be a daily transaction log generated for reconciliation.
* Customers can exchange items directly from their mobile apps.
* Would like to at some point collobrate with other organizations with similar loyalty program so points can be award from them either real-time or maybe based on schedule from their transaction logs. Offers can be displayed and customer can choose to opt-in via their Mobile App. For example, if the customer uses a Credit Card from a certain bank to make the purchase, there would be double points awarded. This would be a beta program.
* Security MUST be a priority and we should design with assumed breach.

## Architecture
1. The solution has a frontend component that requires login from the Customer Service Rep.
2. The solution has an API service that will allow users to lookup members and consume rewards.
3. When the Program changed, all members were assigned a new Member Id. However, not all members have transitioned to the new Program and may be using their old card. Hence, there is a Alternate Id Service that allows Customer Service Rep to search for the member using the old member Id. There will be a grace period and Contoso would like to retire the old member Id in 3 years.
4. Contoso IT has an agreement with the Partner IT to communicate requests via an Enterprise Service Bus (ESB) of their choosing. The Partner development team will subscribe request from the ESB.
5. In order to monitor the health of the system and ensure the SLA is met, there will be Application Monitoring created throughout the system.

![Architecture](/Architecture/Solution.png)

# Topics
Use the following links to get started.

1. [Get started](GETSTARTED.md)
2. [Running .NET solution locally](LOCALDEV.md)

# Demos
Use this Project to showcase the following solutions.

1. [Governance with Azure Blueprint](AZUREBLUEPRINTS.md)
2. [DevOps with GitHub](DEVOPS.md)
3. [Microservices with Frontdoor, AKS, APIM, and AAD B2C](AKS.md)
4. [ETL File Processing with DataFactory](DATAFACTORY.md)

## Have an issue?
You are welcome to create an issue if you need help but please note that there is no timeline to answer or resolve any issues you have with the contents of this project. Use the contents of this project at your own risk! If you are interested to volunteer to maintain this, please feel free to reach out to be added as a contributor and send Pull Requests (PR).