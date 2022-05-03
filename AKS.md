[Main](README.md) | [Internal Customer Service Web App](APP.md) | [ETL Batch Transaction File processing](DATAFACTORY.md)

# Real-time Data Ingestion to award points API Microservice (Frontdoor, AKS, SQL, APIM and AAD)
This solution consist of an real-time data ingestion API endpoint to award points via an internally hosted API Microservice. This solution consist of the following components: Frontdoor, AKS, SQL, APIM and AAD.

## Architecture
1. The solution has a API frontend piece which is created in Azure API Management (APIM).
    1. The frontend API is protected by OAuth and we have created a validate-jwt policy to protect our API,
    2. The Point-Of-Sale Terminals will leverage Client Credentials Flow to get a bearer token from AAD with the provided Client ID and Secret.

![Architecture](/Architecture/AKS.png)

## Other Considerations

# APIM Demo with Postman
1. Install [Postman](https://www.postman.com/downloads/) if it is not yet installed. 
2. Import Test\PointsAPI.postman_collection.json into your Postman
3. Create the following environment variables. Note that you should have these information in Azure Key Vault.
    1. TenantId
    2. ClientId
    3. ClientSecret 
4. Now you can execute the *Client Credentials Flow* step to get the token.
5. Change the URL from *https://demo.contoso.com* to the URL of APIM for both the *Get points* and *Award Points From Transaction* steps.
6. Next, you can execute the *Get points* step to get the points using a Member Id.
7. Lastly, you can execute the *Award Points From Transaction* step and see points being awarded.
8. You can review Application Insights Application Map to review the traffic flow. Note that it could take several minutes before the Application Map shows the traffic flow.