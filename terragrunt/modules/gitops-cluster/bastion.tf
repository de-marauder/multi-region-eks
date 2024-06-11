# Generate a new SSH key pair
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a file
resource "local_file" "bastion_private_key" {
  content  = tls_private_key.bastion_key.private_key_pem
  filename = "${path.module}/../../${local.project_name}-bastion_key.pem"
}

# Create a new AWS key pair for the bastion host
resource "aws_key_pair" "bastion_ssh_key" {
  key_name   = "${local.project_name}-bastion_ssh_key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

# Create a security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  vpc_id      = module.gitops-control-plane.vpc_id
  name        = "${local.project_name}-bastion_sg"
  description = "Security group for the bastion host"

  // Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [module.gitops-control-plane]
}

# Ubuntu AMI data source
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical account ID for Ubuntu AMIs
}

# Launch an EC2 instance for the bastion host
resource "aws_instance" "bastion_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.bastion_ssh_key.key_name
  security_groups             = [aws_security_group.bastion_sg.id]
  subnet_id                   = module.gitops-control-plane.public_subnets[0]
  associate_public_ip_address = true # Assign a public IP for internet access

  user_data = <<EOF
#!/bin/bash

set -e

# Install Dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl unzip

sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${module.gitops-control-plane.cluster_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${module.gitops-control-plane.cluster_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly

# Install Kubectl
sudo apt-get update
sudo apt-get install -y kubectl

# Install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Print the kubectl version for reference
echo "kubectl version: $(kubectl version)"

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

# Install argocd binary
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Configure AWS credentials
su ubuntu -c '
mkdir -p ~/.aws
echo "
[default]
aws_access_key_id = "${var.AWS_ACCESS_KEY}"
aws_secret_access_key = "${var.AWS_SECRET_ACCESS_KEY}"
" > ~/.aws/credentials

# Create Kubeconfig file for gitops (argo) cluster
aws eks update-kubeconfig --name ${local.cluster_name} --region ${var.region} --role-arn ${var.iam_role_arn}

# Install ingress controller
kubectl create namespace ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx  \
  --namespace ingress-nginx \
  --set controller.ingressClassResource.name=nginx

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Setup ArgoCD apps
mkdir ~/github
cd ~/github

git clone ${var.argo_manifest_repo} argo_repo
kubectl apply -f ~/github/argo_repo/${var.argo_manifest_repo_argocd_path}/app-set.yaml
kubectl apply -f ~/github/argo_repo/${var.argo_manifest_repo_argocd_path}/ingress.yaml
'
EOF

  tags = merge(
    {
      Name = "${local.project_name}-Bastion Host"
    },
    local.tags
  )

  lifecycle {
    ignore_changes = [
      security_groups,
    ]
  }
}

