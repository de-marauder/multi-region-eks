locals {
  az_length = length(data.aws_availability_zones.available.names) >= var.min_azs ? var.min_azs : length(data.aws_availability_zones.available.names)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  map_public_ip_on_launch = var.cluster_public

  azs             = slice(data.aws_availability_zones.available.names, 0, local.az_length) // 3 azs per vpc
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = var.tags
}

data "aws_availability_zones" "available" {}
