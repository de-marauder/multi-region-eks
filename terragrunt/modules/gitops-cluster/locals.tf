locals {
  project_name = var.project_name
  cluster_name = "${var.cluster_name}"

  tags = {
    Environment = "${var.tags.Environment}"
    Terraform   = true
  }
}
