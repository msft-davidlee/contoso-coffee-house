[Main](README.md)

# DevOps (CI/CD) with GitHub Actions
GitHub Action allows Developers to do CI/CD. This means that minimally we can also show case Azure Governance and DevOps practices by default along with the three solutions.

# Requirements
This project contains a app.yaml file located in the Deployment directory which contains the full CI/CD codebase. The CI piece will run unit tests, build container images and deploy to a Azure Container Registry. The CD piece will build the networking and Azure app evironment such as AKS and deploy those Container images into AKS.

From a code scanning perspective, the workflows/codeql-analysis.yml contains the code language known as Code QL that specify the scanning parameters such as language and scanning triggers. 

## Steps
1. Create an environment called dev in GitHub secrets. 
2. Create the following secrets as shown in thr secrets section below which are populate with some of the same values as in the shared Azure Key Vault.
    1. The client Id comes from the **Contoso Coffee House GitHub** app registration.
    2. The client secret can be generated from the  **Contoso Coffee House GitHub**.
    3. Use the subscription Id of your Azure Subscription.
    4. Use the tenant Id of your Azure AAD.
3. Create a branch named demo or dev ```git branch checkout -b demo``` and push into your git remote repo to kick off the CI process because it is tied to the name of the git branch: ```git push```
4. You will need to run the CompleteSetup.ps1 script manually in CloudShell or your local Azure CLI ONCE the github action executed successfully.
5. To check if everything is setup successfully, review the script output for any errors.
6. Update your local host file to point to the public ip.

## Secrets
| Name | Value |
| --- | --- |
| CCH_AZURE_CREDENTIALS | <pre>{<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientSecret": "", <br/>&nbsp;&nbsp;&nbsp;&nbsp;"subscriptionId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"tenantId": "" <br/>}</pre> |
| PREFIX | mytodos - or whatever name you would like for all your resources |
| SOURCE_IP | This is your home or office IP. This is applied on NSG to allow you to access your web app |

The following screenshot represents what you should see when you navigate from your repository Settings page and click on Environments.

![Environment Secrets Setup](/doc/SecretsPerEnvironment.png)

# Demo Time!
Follow the steps below to review specific demo pieces.

1. From a high level, we can show that we have 4 distinct jobs. One for 
![GitHub Action](/doc/GitHubAction.png)
2. We can also drill down to each job to see the steps. Note that we treat a job as a unit of work which means if it fails, we can retry a job.
![GitHub Action Job](/doc/GitHubActionJob.png)
3. We can also output artifacts such as the result of unit tests.
![Unit Tests](/doc/UnitTests.png)
4. Lastly, to show case GitHub Advance Security, we can click on the the repository Security tab and select *Secret scanning alerts*. Notice that we have the ability to identity the line of code that needs attention, understand what kind of vulnerability is identified and what recommandations is there. This helps the Developer understand the full end-to-end picture of what is needed.
![GitHub Enterprise Advance Security](/doc/GHEAdvanceSecurity.png)

## Next step
[Internal Customer Service Web App](APP.md) OR [Real-time API Data Ingestion](AKS.md)