locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = "development"
  region   = "${local.env_vars.locals.region}"

  source_base_url = "${get_original_terragrunt_dir()}/../../../../modules//eks-cluster"
}

dependency "iam" {
  config_path = "${get_original_terragrunt_dir()}/../../../shared/iam"
}

dependency "iam" {
  config_path = "${get_original_terragrunt_dir()}/../../../shared/gitops-cluster"
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region}"
    }
    EOF
}

inputs = {
  region = "${local.region}"

  # cluster_public = true

  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]

  managed_worker_node_types     = ["t2.medium"]
  managed_worker_node_count     = 1
  managed_worker_node_min_count = 1
  managed_worker_node_max_count = 2

  cluster_name = "edge-cluster-${local.region}"
  iam_role_arn = "${dependency.iam.outputs.cluster_role_arn}"
  tags = {
    Environment = "${local.env_name}",
    Terraform   = true
  }
}