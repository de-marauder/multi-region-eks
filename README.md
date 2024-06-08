# Multi Region Deploymnt of kuberneted using AWS EKS

This project demonstrates how to perform multi-region deployment of kubernetes using AWS EKS clusters

## Tools
- Terraform
- ArgoCD

## Objectives
- [x] Create a terraform module that encapsulates the infrastructure requirements.
  - [x] Make use of an appropriate data structure to allow for region specific modification of the deployment.
  - [x] Make use of terragrunt to organize terraform modules deployments
- [X] Create relevant kubernetes manifests
  - [X] For Argo CD control plane
  - [X] For deployed infrastructure
- [X] Make use of a centralized push based architecture for ArogoCD GitOps deployment.
- [X] Showcase how secrets/credentials should be handled
- [ ] Showcase how databases should be handled
