[Main](README.md)

# Introduction
GitHub Action allows Developers to do CI and CD. This means that minimally we can also show case Azure Governance and DevOps practices by default along with the solutions.

# Requirements
This project contains a app.yaml file located in the Deployment directory which contains the full CI/CD codebase. The CI piece will run unit tests, build container images and deploy to a Azure Container Registry. The CD piece will build the networking and Azure app evironment such as AKS and deploy those Container images into AKS.

## Steps
1. Create a branch named demo or dev and push into your git remote repo to kick off the CI process because it is tied to the name of the git branch.
2. You will need to run the CompleteSetup.ps1 script manually in CloudShell or your local Azure CLI.
3. To check if everything is setup successfully, review the script output for any errors.
4. Update your local host file to point to the public ip.