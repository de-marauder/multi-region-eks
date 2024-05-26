include "root" {
  path = "${find_in_parent_folders()}"
}

include "env" {
  path   = "${get_parent_terragrunt_dir()}/../../../_env/gitops-cluster.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}"
}
