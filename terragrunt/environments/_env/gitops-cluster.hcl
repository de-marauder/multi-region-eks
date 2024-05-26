locals {
  environment_var = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env_name = "${local.environment_var.locals.environment}"
  region = "${local.environment_var.locals.default_region}"

  source_base_url = "${get_parent_terragrunt_dir()}/../../modules//gitops-cluster"
}

dependency "iam" {
  config_path = "${get_original_terragrunt_dir()}/../../shared/iam"
}

inputs = {
  region = "${local.region}"

  cluster_name = "gitops-cluster-${local.region}"
  iam_role_arn = "${dependency.iam.outputs.cluster_role_arn}"
  tags = {
    Environment = "${local.env_name}",
    Terraform   = true
  }
}
