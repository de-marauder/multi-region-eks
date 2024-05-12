# Multi Region Deploymnt of kuberneted using AWS EKS

This project demonstrates how to perform multi-region deployment of kubernetes using AWS EKS clusters

## Tools
- Terraform
- ArgoCD

## Objectives
- [ ] Create a terraform module that encapsulates the infrasture requirements.
  - [ ] Make use of an appropriate data structure to allow for region specific modification of the deployment.
- [ ] Create relevant kubernetes manifests
  - [ ] For Argo CD control plane
  - [ ] For deployed infrastructure
- [ ] Make use of a centralized push based architecture for ArogoCD GitOps deployment.
- [ ] Showcase how secrets/credentials should be handled
- [ ] Showcase how databases should be handled
