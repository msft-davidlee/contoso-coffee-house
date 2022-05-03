[Main](README.md) | [Internal Customer Service Web App](APP.md) | [Real-time API Data Ingestion](AKS.md)

# ETL Batch Transaction File processing for reconciliation of awarding points (Storage, DataFactory, SQL, AKS, APIM and AAD)
This solution consist of Storage for where the Transaction File is posted and Azure Data Factory for processing the file on the backend. The award of points will invoke calls via APIM to backend microservice hosted on AKS.

## Architecture
1. The Azure Storage will allow files to be posted via Storage Explorer, Azure CLI and or AzCopy, all of the tools are free and can leverage security mechanism such as SAS keys which provides ability to control and limit access.
2. The Data Factory Pipeline will get triggered from an event when the CSV Transaction file is posted and a script would parse the CSV into JSON structure to trigger API to the backend.
3. We will be able to leverage the same API microservice hosted on the AKS cluster for [Real-time API Data Ingestion](AKS.md) to process the transaction which means we are reusing the same business logic/code. We will also be able to monitor the performance using the same Application Insights infrastructure. 

![Architecture](/Architecture/DATAFACTORY.png)

## Other Considerations
1. We could also have a version of our API microservice to take in batch transactions which will greatly reduce the number of calls from the transaction log. From the real-time data ingestion persepctive, we could rework APIM to convert the "single call" to a "batch" structure. This means our POS Terminals do NOT have any code to change and we would be more performant for both use cases.

# Transaction File Processing Demo
1. Create a CSV file with the following format. Be sure to use valid Member ID and SKUs as listed in the [SQL migration script](DB/Migrations.sql). Use the following format:
```
<MEMBER ID>,<TRANSACTION DATE>,<LINE NUMBER>,<TRANSACTION ID>,<SKU>,<DOLLAR AMT ROUNDED>
5325553303,2022-03-23,1,TRAN0100ABC,DUS872344,7
```
2. Generate a SAS key and use your favorite tool to upload the file to the Storage Account your Azure Data Factory (ADF) will pull the CSV file from.
3. The ADF pipeline will execute and invoke the API to provision missing transactions.
4. When the process is completed, you can now login to the portal https://demo.contoso.com to check the points as a user who is assigned the role of Customer Service Agent.
5. Review the ADF pipeline to review the steps in the pipeline in ADF. You will notice API calls to the API endpoint.
6. You can also review Application Insights and the Map feature to see the traffic flow.