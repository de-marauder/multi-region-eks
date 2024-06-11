include "root" {
  path = "${find_in_parent_folders()}"
}

include "env" {
  path   = "${get_parent_terragrunt_dir()}/../../../_env/gitops-cluster.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}"

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
