output "bastion_public_ip" {
  value = aws_instance.bastion_instance.public_ip
}

output "bastion_public_dns" {
  value = aws_instance.bastion_instance.public_dns
}

output "vpc_id" {
  value = module.gitops-control-plane.vpc_id
}

output "public_subnets" {
  value = module.gitops-control-plane.public_subnets
}

output "private_subnets" {
  value = module.gitops-control-plane.private_subnets
}

output "cluster_endpoint" {
  value = module.gitops-control-plane.cluster_endpoint
}

output "cluster_access_entries" {
  value = module.gitops-control-plane.cluster_access_entries
}

output "cluster_arn" {
  value = module.gitops-control-plane.cluster_arn
}

output "vpc_cidr" {
  value = module.gitops-control-plane.vpc_cidr
}

output "region" {
  value = var.region
}

output "private_route_table_ids" {
  value = module.gitops-control-plane.private_route_table_ids
}

output "public_route_table_ids" {
  value = module.gitops-control-plane.public_route_table_ids
}