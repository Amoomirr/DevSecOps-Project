provider "aws" {
  region = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "vpc" {
  source = "./module/vpc"
}
resource "aws_instance" "Jenkins" {
  ami = var.ami_value
  instance_type = var.instance_type_value
  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.aws_security_group]

   root_block_device {
    volume_size = 20      
    volume_type = "gp3"     
    delete_on_termination = true
  }

  tags = {
    Name = "Netflix-Jenkins"
  }

 user_data = <<EOF
#!/bin/bash
sudo su
apt update 
apt install -y docker.io
usermod -aG docker $USER && newgrp docker
apt install -y fontconfig openjdk-21-jre

wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt update 
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins
EOF
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster (Using Your VPC Module)
resource "aws_eks_cluster" "netflix_eks" {
  name     = "netflix-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = module.vpc.public_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# IAM Role for Worker Nodes
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

# Node Group (2 Worker Nodes Fixed)
resource "aws_eks_node_group" "netflix_nodes" {
  cluster_name    = aws_eks_cluster.netflix_eks.name
  node_group_name = "netflix-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.public_subnet_ids

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }

  instance_types = [var.instance_type_value]

  depends_on = [
    aws_iam_role_policy_attachment.node_policies
  ]
} 