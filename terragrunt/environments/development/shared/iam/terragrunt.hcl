include "root" {
  path   = "${find_in_parent_folders()}"
  expose = true
}

locals {
  env_var = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment = "${local.env_var.locals.environment}"
  project_name = "${include.root.locals.project_name}"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//iam"
}

inputs = {
  env          = "${local.environment}"
  project_name = "${local.project_name}"
}
