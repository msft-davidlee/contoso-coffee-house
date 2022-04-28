[Main](README.md)

# Introduction
This solution consist of an internal Customer Service Web App with a backend points-for-rewards jobs processing. This solution consist of the following components: Frontdoor, AKS, SQL, Functions, Service Bus and AAD.

## Architecture
1. The solution has a frontend component that requires login from the Customer Service Rep.
2. The solution has an API service that will allow users to lookup members and consume rewards.
3. When the Program changed, all members were assigned a new Member Id. However, not all members have transitioned to the new Program and may be using their old card. Hence, there is a Alternate Id Service that allows Customer Service Rep to search for the member using the old member Id. There will be a grace period and Contoso would like to retire the old member Id in 3 years.
4. Contoso IT has an agreement with the Partner IT to communicate requests via an Enterprise Service Bus (ESB) of their choosing. The Partner development team will subscribe request from the ESB.
5. In order to monitor the health of the system and ensure the SLA is met, there will be Application Monitoring created throughout the system.

![Architecture](/Architecture/Solution.png)

## Other Considerations
1. This solution employs a microservice architecture where we have the API and legacy API service in relation to the Member Id question. It may not make sense for the business to include the old Member Id as part of the new system as it will be retired in 3 years. As such, we are keeping the legacy API. Here, it may make sense to think about leveraging APIM so we have a consistent API experience for our microservice.
2. The Enterprise Service Bus approach is an interesting way for Contoso to "expose" their request to a third party because this is typically done by making a call to the third party endpoint. However, not all third party vendors will host their applications as services on the internet as their core business is not in technology but in fulfillment. Hence, the ESB approach will allow the most flexibility for any third party vendors. For example, if a vendor already has an API endpoint, they can simply create a proxy app to subscribe and push the request to their API. If they don't, they will create an app to subscribe to the ESB and consume the fulfillment request.
3. The security of the web app is taken care of using Identity Providers rather than a custom authentication approach (think asp.net forms authentication where we end up creating our own identity store in the olden days). A third party approach like AAD B2B or B2C means Contoso can get developers to focus on business problems and leave authentication and authorization to the experts.

# Demo Time!
Follow the steps below to review specific demo pieces.

## Customer Service App Demo
1. Launch https://demo.contoso.com which will prompt you to login. 
2. You can review the member list in the [SQL migration script](DB/Migrations.sql). For example you can use "Hami Young".
3. Use this to lookup a member by First Name and Last Name.
4. Click on Check eligible reward.
5. Click Redeem on any items and you can see the either a prompt saying "Member has X points remaining..." OR "Sorry, product is not in stock, please choose a different reward.". If you see the latter, try a different Product.
6. What is happening on the backend is that we have several microservices and when Redeem is clicked on, the Customer Service Web App will invoke a call to another Microservice to "make" the Order to the Partner site. The Order will be dropped into a Service Bus queue. We have created an Azure Function to simulate what the Partner will be doing and this Azure Function gets triggered based on messages on this Service Bus queue. The Azure Function will complete the order by attaching a "Shipping Tracking Number"
7. Click on "Check reward orders" to see if the order is processed.
8. We should also note that on the backend, we are making several SQL calls to get latest points and updating latest points for members.

## Accompanying Demos
1. Once we have completed the Customer Service App Demo, we can bring up Application insights to demonstrate Application Map as that will show all the different moving parts.
    1. If there are errors, we can also showcase that experience by doing "Transaction search" or viewing "Failures".
2. Next, we can review Azure Service Bus and in the overview sceeen, we can take a look at the request and messages. We can track the rate of messages, whether messages are throttled and other interesting insights.
3. Lastly, we can review AKS and review the "Services and ingresses". We can talk about using the Portal to review the ingress configurations (where we have multiple websites), reviewing the Pods and health status, logs and many other capabilities.