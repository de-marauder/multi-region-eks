# IaC using Terragrunt

Terragrunt is a wrapper around terraform that helps manage terraform modules deployments for multi-region or multi-environment infrastructure in a DRY way.

## Motivation

This setup aimed to show how a multi region deployment can be structured using best practices and DRY methodologies. It can serve as a robust template for high availability deployment and resilient infrastructure whether you are interested in disaster recovery or traffic distribution.


The project is structured like so:

```
../terragrunt/
├── environments
│   ├── development
│   │   ├── env.hcl
│   │   ├── regions
│   │   │   ├── us-east-2
│   │   │   │   ├── edge-cluster
│   │   │   │   │   └── terragrunt.hcl
│   │   │   │   ├── region.hcl
│   │   │   │   ├── vpc-peer-connection-accepter
│   │   │   │   │   └── terragrunt.hcl
│   │   │   │   └── vpc-peering-requester
│   │   │   │       └── terragrunt.hcl
│   │   │   └── us-west-2
│   │   │       ├── edge-cluster
│   │   │       │   └── terragrunt.hcl
│   │   │       ├── region.hcl
│   │   │       ├── vpc-peer-connection-accepter
│   │   │       │   └── terragrunt.hcl
│   │   │       └── vpc-peering-requester
│   │   │           └── terragrunt.hcl
│   │   └── shared
│   │       ├── gitops-cluster
│   │       │   └── terragrunt.hcl
│   │       └── iam
│   │           └── terragrunt.hcl
│   ├── _env
│   │   ├── edge-cluster.hcl
│   │   ├── gitops-cluster.hcl
│   │   ├── vpc-peering-conn-accepter.hcl
│   │   └── vpc-peering-conn-requester.hcl
│   └── production
├── env.yaml
├── modules
│   ├── eks-cluster
│   │   ├── eks.tf
│   │   ├── outputs.tf
│   │   ├── sg.tf
│   │   ├── variables.tf
│   │   └── vpc.tf
│   ├── gitops-cluster
│   │   ├── bastion.tf
│   │   ├── locals.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── locals.tf
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── vpc-peering-accepter
│   │   ├── main.tf
│   │   └── variables.tf
│   └── vpc-peering-requester
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── README.md
├── terraform.tfstate
└── terragrunt.hcl
```

## Description

EKS clusters are deployed to edge regions (in this case 2 but can be scaled up). These eks clusters are then connected to a gitops cluster which watches a git repo and pushes changes to the kubernetes state files (manifests) to all clusters depending on the configurations available.

Connections between VPCs across regions are handled with VPC peer connections. The network topolopgy is a hub and spoke pattern where the gitops cluster VPC serves as a hub and the egde clusters are the spoke. The edge clusters each serve their own traffic however, and only rely on the gitops cluster for updates.

//TODO: Include an image showing the architecture topology

Since the deployment is done in a private network for security reasons, a bastion is provisioned for access. This bastion comes with the gitops cluster module and can access all edge clusters due to the VPC peer connections

## Usage

To run the terragrunt configuration, run the following command
```bash
terragrunt run-all plan
terragrunt run-all apply
```

One thing I like about terragrunt is that if you want to use a remote backend as you should, terragrunt can detect if it exists in your cloud and provision it for you if it does not. So your backend gets managed in the same scope as your deployment.

Please reference the [official terragrunt docs](https://terragrunt.gruntwork.io/docs/) for more information about installation and usage.

## Extras
Right now the production environment is empty but can be populated by updating configurations from the development environment.