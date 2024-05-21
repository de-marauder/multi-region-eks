locals {
  project_name = var.project_name
  cluster_name = "${var.project_name}-${var.region}"

  tags = {
    Environment = var.tags.Environment
    Terraform   = true
  }
}
