variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "cluster_public" {
  default = false
  type    = bool
}

variable "eks_version" {
  type    = string
  default = "1.29"
}

variable "iam_role_arn" {
  type = string
}

variable "tags" {
  description = "Environment must be either 'dev' or 'prod'"

  type = object({
    Environment = string
    Terraform   = bool
  })
}

variable "min_azs" {
  type        = number
  default     = 3 # Minimum number of AZs required
  description = "Minimum number of Availability Zones for the VPC"
}

variable "self_managed_node_groups_present" {
  type    = bool
  default = false
}
variable "managed_node_groups_present" {
  type    = bool
  default = true
}

variable "managed_worker_node_types" {
  type    = list(string)
  default = ["t2.medium", "t3.small", "t2.large"]
}

variable "managed_worker_node_count" {
  type    = number
  default = 3
}

variable "managed_worker_node_min_count" {
  type    = number
  default = 1
}
variable "managed_worker_node_max_count" {
  type    = number
  default = 5
}

variable "self_managed_worker_node_types" {
  type    = list(string)
  default = [""]
}

variable "self_managed_worker_node_count" {
  type    = number
  default = 1
}

variable "self_managed_worker_node_min_count" {
  type    = number
  default = 1
}
variable "self_managed_worker_node_max_count" {
  type    = number
  default = 1
}

variable "ebs_addon_present" {
  type = bool
  default = false
}

variable "bastion_security_group_ids" {
  type    = list(string)
  default = []
}
