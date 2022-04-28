[Main](README.md)

# Introduction
This solution consist of an real-time data ingestion API endpoint to award points via an internally hosted API Microservice. This solution consist of the following components: Frontdoor, AKS, SQL, APIM and AAD.

## Architecture
1. The solution has a API frontend piece which is created in Azure API Management (APIM).
    1. The frontend API is protected by OAuth and we have created a validate-jwt policy to protect our API,
    2. The Point-Of-Sale Terminals will leverage Client Credentials Flow to get a bearer token from AAD with the provided Client ID and Secret. 
4. Contoso IT has an agreement with the Partner IT to communicate requests via an Enterprise Service Bus (ESB) of their choosing. The Partner development team will subscribe request from the ESB.
5. In order to monitor the health of the system and ensure the SLA is met, there will be Application Monitoring created throughout the system.

![Architecture](/Architecture/Solution.png)

## Other Considerations

