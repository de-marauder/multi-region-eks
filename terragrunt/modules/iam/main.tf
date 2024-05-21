# IAM Role for EKS Cluster Access
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.project_name}-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
          # // You can add iam user arns to attach roles to them
          # // This will allow them to assume this role
          # # "AWS" : "arn:aws:iam::xxxxxxxxx:user/xxxxxxxxx"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

data "aws_iam_policy" "eks_cluster_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  tags = local.tags
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "eks_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = data.aws_iam_policy.eks_cluster_policy.arn
}

