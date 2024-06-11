locals {
  ebs_driver_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ebs_driver_role_name = "${var.cluster_name}-${var.ebs_driver_role_name}"
}

data "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = var.cluster_oidc_issuer_url
}

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks_oidc_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.cluster_oidc_issuer}:sub"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account}"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${local.ebs_driver_role_name}"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = local.ebs_driver_policy_arn
}

module "ebs_csi_sa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${local.ebs_driver_role_name}"
  role_policy_arns = {
    policy = "${local.ebs_driver_policy_arn}"
  }
  create_role = false

  oidc_providers = {
    one = {
      provider_arn               = "${data.aws_iam_openid_connect_provider.eks_oidc_provider.arn}"
      namespace_service_accounts = ["${var.service_account_namespace}:${var.service_account}"]
    }
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
}
