include "env" {
  path   = "${get_parent_terragrunt_dir()}/../../../_env/gitops-cluster.development.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}"
}
