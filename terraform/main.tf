terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

# Récupérer le rôle LabRole existant
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Récupérer l'account ID
data "aws_caller_identity" "current" {}

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "simple-vpc"
    "kubernetes.io/cluster/simple-eks" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "simple-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = "us-east-1${count.index == 0 ? "a" : "b"}"
  map_public_ip_on_launch = true

  tags = {
    Name = "simple-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/simple-eks" = "shared"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = "us-east-1${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "simple-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/simple-eks" = "shared"
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "simple-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "simple-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "simple-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "simple-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Group pour EKS
resource "aws_security_group" "eks_cluster" {
  name        = "simple-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "simple-eks-cluster-sg"
  }
}

# EKS Cluster utilisant LabRole
resource "aws_eks_cluster" "main" {
  name     = "simple-eks"
  role_arn = data.aws_iam_role.lab_role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  tags = {
    Name = "simple-eks"
  }
}

# EKS Node Group utilisant LabRole
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "simple-node-group"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "simple-node-group"
  }
}