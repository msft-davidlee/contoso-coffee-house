[Main](README.md)

# Introduction
We will host this solution in Azure Kubernetes Service (AKS)

The technology stack used includes .NET 6, MS SSQL, Azure Service Bus, and Azure Functions for processing backend requests. Most services can be run and debugged locally via emulators except for Azure Service Bus.

# Requirements
1. This solution employs a microservice architecture where we have the API and legacy API service in relation to the Member Id question. It may not make sense for the business to include the old Member Id as part of the new system as it will be retired in 3 years. As such, we are keeping the legacy API. Here, it may make sense to think about leveraging APIM so we have a consistent API experience for our microservice.
2. The Enterprise Service Bus approach is an interesting way for Contoso to "expose" their request to a third party because this is typically done by making a call to the third party endpoint. However, not all third party vendors will host their applications as services on the internet as their core business is not in technology but in fulfillment. Hence, the ESB approach will allow the most flexibility for any third party vendors. For example, if a vendor already has an API endpoint, they can simply create a proxy app to subscribe and push the request to their API. If they don't, they will create an app to subscribe to the ESB and consume the fulfillment request.
3. The security of the web app is taken care of using Identity Providers rather than a custom authentication approach (think asp.net forms authentication where we end up creating our own identity store in the olden days). A third party approach like AAD B2B or B2C means Contoso can get developers to focus on business problems and leave authentication and authorization to the experts.

# Architecture
1. The solution has a frontend component that requires login from the Customer Service Rep.
2. The solution has an API service that will allow users to lookup members and consume rewards.
3. When the Program changed, all members were assigned a new Member Id. However, not all members have transitioned to the new Program and may be using their old card. Hence, there is a Alternate Id Service that allows Customer Service Rep to search for the member using the old member Id. There will be a grace period and Contoso would like to retire the old member Id in 3 years.
4. Contoso IT has an agreement with the Partner IT to communicate requests via an Enterprise Service Bus (ESB) of their choosing. The Partner development team will subscribe request from the ESB.
5. In order to monitor the health of the system and ensure the SLA is met, there will be Application Monitoring created throughout the system.

![Architecture](/Architecture/Solution.png)