[Main](README.md) | [Internal Customer Service Web App](APP.md) | [Real-time API Data Ingestion](AKS.md)

# ETL Batch Transaction File processing for reconciliation of awarding points (Storage, Databricks, SQL, AKS, APIM and AAD)
This solution consist of Storage for where the Transaction File is posted and Azure Databricks for processing the file on the backend. The award of points will invoke calls via APIM to backend microservice hosted on AKS.

## Architecture
1. The Azure Storage will allow files to be posted via Storage Explorer, Azure CLI and or AzCopy, all of the tools are free and can leverage security mechanism such as SAS keys which provides ability to control and limit access.
2. The Azure Databricks notebooks can be manually run or executed on a trigger via a Data Factory pipeline, and include scripts to parse the CSV into JSON structure to trigger API to the backend.
3. We will be able to leverage the same API microservice hosted on the AKS cluster for [Real-time API Data Ingestion](AKS.md) to process the transaction which means we are reusing the same business logic/code. We will also be able to monitor the performance using the same Application Insights infrastructure. 

![Architecture](/Architecture/AKS.png)

## Other Considerations
1. We could also have a version of our API microservice to take in batch transactions which will greatly reduce the number of calls from the transaction log. From the real-time data ingestion persepctive, we could rework APIM to convert the "single call" to a "batch" structure. This means our POS Terminals do NOT have any code to change and we would be more performant for both use cases.
2. We opted to use Azure Databricks as our batch processing engine, however with some minor modifications to the Python notebooks (the Databricks File System part of the code) we could implement this batch process in Azure Synapse Analytics using Synapse Spark, while also being able to create a data warehouse based on historical transaction log files.

# Transaction File Processing Demo
1. Import the three .ipynb notebooks located in the Batch Processing folder into a Databricks workspace. 
2. To generate a Transaction File in CSV format execute notebook #1, [DataGenerator.ipynb](BatchProcessing/1DataGenerator.ipynb). This will generate a transaction file with a user-specified number of records, and upload the file to your Azure Storage Container using DBFS. Follow the commented steps within each notebook and supply the proper information such as SAS Key, Storage Account name, APIM Hostname, etc.
3. Once the CSV file is generated and uploaded to Azure Storage, execute notebook #2, [ConvertCSVtoJSON.ipynb](BatchProcessing/2ConvertCSVtoJSON.ipynb) to parse the CSV file and upload a new file into your Storage Account in JSON format.
4. Once the JSON file is uploaded to Azure Storage, execute notebook #3, [BatchAPI_Ingestion.ipynb](BatchProcessing/3BatchAPI_Ingestion.ipynb) to send the transaction file to the Rewards API, which will create missing transactions in the system from the JSON file.
    *OPTIONAL*: You can automate the execution of notebooks #2 and #3 on the event of a transaction file being uploaded using Azure Data Factory Pipelines. To do so, add your Databricks workspace as a linked service in ADF, and create a pipeline that runs the Databricks notebooks. Create a storage event pipeline trigger on your Azure Storage container, filtering on 'blob created' events for files ending in '.csv'.
5. When the process is completed, you can now login to the portal https://demo.contoso.com to check the points as a user who is assigned the role of Customer Service Agent.
6. You can also review Application Insights and the Map feature to see the traffic flow.