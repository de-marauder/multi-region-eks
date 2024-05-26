include "root" {
  path   = "${find_in_parent_folders()}"
  expose = true
}

locals {
  project_name = "${include.root.locals.project_name}"
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../../../../environments/_env/vpc-peering-conn-accepter.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}"
}

inputs = {
  project_name = "${local.project_name}"
}