variable "cluster_oidc_issuer_url" {
  type = string
}
variable "cluster_oidc_issuer" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "ebs_driver_role_name" {
  type = string
  default = "AmazonEKS_EBS_CSI_DriverRole"
}

variable "service_account" {
  type = string
  default = "ebs-csi-controller-sa"
}

variable "service_account_namespace" {
  type = string
  default = "kube-system"
}

variable "tags" {
  default = {
    managedBy = "Terraform"
  }
}