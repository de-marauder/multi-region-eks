remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "my-multi-cluster-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    // dynamodb_table = "my-multi-cluster-lock-table"
  }
}

locals {
  env_vars     = yamldecode(file("./env.yaml"))
  region   = "${local.env_vars["aws_region"]}"
  project_name = "${local.env_vars["project_name"]}"
}


generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
  profile = "terraform"
  alias = "${local.region}"
  default_tags {
   tags = {
      project  = "${local.project_name}"
      terraform = true
   }
  }
}
EOF
}