module "gitops-control-plane" {
  source = "../eks-cluster"

  region = var.region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  managed_worker_node_types     = var.managed_worker_node_types
  managed_worker_node_count     = 1
  managed_worker_node_min_count = 1
  managed_worker_node_max_count = 2

  cluster_name = local.cluster_name
  iam_role_arn = var.iam_role_arn
  tags         = local.tags
}
