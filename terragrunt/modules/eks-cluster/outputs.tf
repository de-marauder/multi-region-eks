output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "cluster_version" {
  value = var.eks_version
}
output "cluster_access_entries" {
  value = module.eks.access_entries
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_cert" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "managed_nodes" {
  value = module.eks.eks_managed_node_groups
}

output "self_managed_nodes" {
  value = module.eks.self_managed_node_groups
}

output "region" {
  value = var.region
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}