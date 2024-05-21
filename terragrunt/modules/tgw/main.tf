
module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name        = "${var.project_name}-tgw"
  description = var.description

  enable_auto_accept_shared_attachments = true

  vpc_attachments = var.vpc_attachments

  ram_allow_external_principals = true
  ram_principals = [307990089504]

  tags = {
    Environment = var.env
    Terraform = true
  }
}
