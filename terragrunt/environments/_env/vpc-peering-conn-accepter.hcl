locals {
  environment_var = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_var      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env_name = "${local.environment_var.locals.environment}"
  region   = "${local.region_var.locals.region}"

  source_base_url = "${get_original_terragrunt_dir()}/../../../../../modules//vpc-peering-accepter"
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

dependency "gitops-cluster" {
  config_path = "${get_original_terragrunt_dir()}/../../../shared/gitops-cluster"
}

dependency "edge-cluster" {
  config_path = "${get_original_terragrunt_dir()}/../edge-cluster"
}

dependency "requester" {
  config_path = "${get_original_terragrunt_dir()}/../vpc-peering-requester"
}

inputs = {
  peer_connection_id = "${dependency.requester.outputs.peer_connection_id}"
  peer_region        = "${dependency.gitops-cluster.outputs.region}"
  public_route_table_id     = "${dependency.edge-cluster.outputs.public_route_table_ids[0]}"
  private_route_table_id     = "${dependency.edge-cluster.outputs.private_route_table_ids[0]}"
  destination_cidr   = "${dependency.gitops-cluster.outputs.vpc_cidr}"
  region             = "${local.region}"
  environment        = "${local.env_name}"
}