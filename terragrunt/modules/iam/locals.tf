locals {
  project_name = var.project_name

  tags = {
    Environment = "${var.env}"
    # Terraform   = true
  }
}
