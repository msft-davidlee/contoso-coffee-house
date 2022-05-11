[Main](README.md)

# DevOps (CI/CD) with GitHub Actions
GitHub Action allows Developers to do CI/CD. This means that minimally we can also show case Azure Governance and DevOps practices by default along with the three solutions.

# Requirements
This project contains a app.yaml file located in the Deployment directory which contains the full CI/CD codebase. The CI piece will run unit tests, build container images and deploy to a Azure Container Registry. The CD piece will build the networking and Azure app evironment such as AKS and deploy those Container images into AKS.

From a code scanning perspective, the workflows/codeql-analysis.yml contains the code language know as Code QL that specify the scanning parameters such as language and scanning triggers. 

## Steps
1. Create a branch named demo or dev ```git branch checkout -b demo``` and push into your git remote repo to kick off the CI process because it is tied to the name of the git branch: ```git push```
2. Create the secret(s) in your github dev environment as defined in secrets section below. Be sure to populate with your desired values from the previous steps.
3. You will need to run the CompleteSetup.ps1 script manually in CloudShell or your local Azure CLI.
4. To check if everything is setup successfully, review the script output for any errors.
5. Update your local host file to point to the public ip.

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