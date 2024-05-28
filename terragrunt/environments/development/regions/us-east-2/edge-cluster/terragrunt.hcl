include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../../../../environments/_env/edge-cluster.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}"
}

inputs = {
  vpc_cidr             = "10.11.0.0/16"
  public_subnet_cidrs  = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
  private_subnet_cidrs = ["10.11.11.0/24", "10.11.12.0/24", "10.11.13.0/24"]
}
