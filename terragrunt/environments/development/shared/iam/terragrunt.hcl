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

  extra_arguments "secrets" {
    commands = [
      "apply",
      "plan",
      "destroy"
    ]

    arguments = [
      "-var-file=${get_original_terragrunt_dir()}/secrets.tfvars"
    ]
  }
}

inputs = {
  env          = "${local.environment}"
  project_name = "${local.project_name}"
}
