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

  depends_on = [ module.gitops-control-plane ]
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

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl

# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${module.gitops-control-plane.cluster_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${module.gitops-control-plane.cluster_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly

sudo apt-get update
sudo apt-get install -y kubectl

# Install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Print the kubectl version for reference
echo "kubectl version: $(kubectl version --client-version)"

EOF


  tags = merge(
    {
      Name = "${local.project_name}-Bastion Host"
    },
    local.tags
  )

  depends_on = [ module.gitops-control-plane ]
}

