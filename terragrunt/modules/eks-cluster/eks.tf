module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = var.cluster_public ? module.vpc.public_subnets : module.vpc.private_subnets // cluster should be private
  control_plane_subnet_ids = module.vpc.intra_subnets
  cluster_additional_security_group_ids = [
    "${aws_security_group.remote_access.id}"
  ]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = "${var.managed_worker_node_types}"
  }
  self_managed_node_group_defaults = {
    instance_types = "${var.self_managed_worker_node_types}"
  }

  self_managed_node_groups = var.self_managed_node_groups_present ? {
    workers = {
      min_size     = "${var.self_managed_worker_node_min_count}"
      max_size     = "${var.self_managed_worker_node_max_count}"
      desired_size = "${var.self_managed_worker_node_count}"

      instance_types = "${var.self_managed_worker_node_types}"
      capacity_type  = "ON_DEMAND"

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = "${module.key_pair.key_pair_name}"
        source_security_group_ids = ["${aws_security_group.remote_access.id}"]
      }
    }

  } : {}

  eks_managed_node_groups = var.managed_node_groups_present ? {
    workers = {
      min_size     = "${var.managed_worker_node_min_count}"
      max_size     = "${var.managed_worker_node_max_count}"
      desired_size = "${var.managed_worker_node_count}"

      instance_types = "${var.managed_worker_node_types}"
      capacity_type  = "ON_DEMAND"
    }
  } : {}

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    admin = {
      kubernetes_groups = []
      principal_arn     = "${var.iam_role_arn}"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

  }

  tags = var.tags
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = "${var.cluster_name}-node-key-pair"
  create_private_key = true

  tags = var.tags
}

resource "local_file" "ssh_private_key" {
  filename   = "../../${var.cluster_name}.pem" # Replace with the desired path and filename
  content    = module.key_pair.private_key_pem
  depends_on = [module.key_pair] # Ensure that the private key is generated before writing to the file
}

resource "local_file" "ssh_public_key" {
  filename   = "../../${var.cluster_name}.pub" # Replace with the desired path and filename
  content    = module.key_pair.public_key_openssh
  depends_on = [module.key_pair] # Ensure that the public key is generated before writing to the file
}
