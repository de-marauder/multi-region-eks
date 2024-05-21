terraform {
  source = "${get_parent_terragrunt_dir()}/../../../../modules//iam"
}

inputs = {
  env          = "development"
  project_name = "multi-cluster"
}
