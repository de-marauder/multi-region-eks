variable "project_name" {
  type    = string
  default = "GitOps-Control"
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

variable "cluster_name" {
  type = string
}

variable "cluster_public" {
  default = false
  type    = bool
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

variable "managed_node_groups_present" {
  type    = bool
  default = true
}

variable "managed_worker_node_types" {
  type    = list(string)
  default = ["t2.medium"]
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

variable "bastion_instance_type" {
  type    = string
  default = "t2.medium"
}
