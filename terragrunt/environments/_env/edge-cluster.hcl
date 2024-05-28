locals {
  environment_var = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_var      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env_name = "${local.environment_var.locals.environment}"
  region   = "${local.region_var.locals.region}"

  source_base_url = "${get_original_terragrunt_dir()}/../../../../../modules//eks-cluster"
}

generate "provider" {
  path      = "${local.region}_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region}"
    }
    EOF
}

dependency "iam" {
  config_path = "${get_original_terragrunt_dir()}/../../../shared/iam"
}

dependency "gitops-cluster" {
  config_path = "${get_original_terragrunt_dir()}/../../../shared/gitops-cluster"
  // skip_outputs = true
}

inputs = {
  region = "${local.region}"

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