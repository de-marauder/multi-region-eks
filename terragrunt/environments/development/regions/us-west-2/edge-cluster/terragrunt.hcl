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
  vpc_cidr             = "10.12.0.0/16"
  public_subnet_cidrs  = ["10.12.1.0/24", "10.12.2.0/24", "10.12.3.0/24"]
  private_subnet_cidrs = ["10.12.11.0/24", "10.12.12.0/24", "10.12.13.0/24"]
}
