[Main](README.md)

# Introduction
GitHub Action allows Developers to do CI and CD. 

# Requirements
This project contains a app.yaml file located in the Deployment directory which contains the full CI/CD codebase. The CI piece will run unit tests, build container images and deploy to a Azure Container Registry. The CD piece will build the networking and Azure app evironment such as AKS and deploy those Container images into AKS.