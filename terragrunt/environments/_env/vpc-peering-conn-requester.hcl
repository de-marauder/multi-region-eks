locals {
  environment_var = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_var      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env_name    = "${local.environment_var.locals.environment}"
  peer_region = "${local.region_var.locals.region}"

  source_base_url = "${get_original_terragrunt_dir()}/../../../../../modules//vpc-peering-requester"
}

generate "provider" {
  path      = "${dependency.gitops-cluster.outputs.region}_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${dependency.gitops-cluster.outputs.region}"
    }
    EOF
}

dependency "edge-cluster" {
  config_path = "${get_original_terragrunt_dir()}/../edge-cluster"
}

dependency "gitops-cluster" {
  config_path = "${get_original_terragrunt_dir()}/../../../shared/gitops-cluster"
}

inputs = {
  peer_vpc_id = "${dependency.edge-cluster.outputs.vpc_id}"
  vpc_id      = "${dependency.gitops-cluster.outputs.vpc_id}"
  peer_region = "${local.peer_region}"
  public_route_table_id = "${dependency.gitops-cluster.outputs.public_route_table_ids[0]}"
  private_route_table_id = "${dependency.gitops-cluster.outputs.private_route_table_ids[0]}"
  destination_cidr = "${dependency.edge-cluster.outputs.vpc_cidr}"
  region      = "${dependency.gitops-cluster.outputs.region}"

  environment = "${local.env_name}"

}