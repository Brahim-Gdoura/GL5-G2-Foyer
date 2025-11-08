# Availability Zones
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "eks-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "eks_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-${count.index + 1}"
  }
}

# Create IAM Role if not provided
resource "aws_iam_role" "eks_role" {
  count = var.eks_role_arn == "" ? 1 : 0

  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach EKS policy
resource "aws_iam_role_policy_attachment" "eks_policy" {
  count      = var.eks_role_arn == "" ? 1 : 0
  role       = aws_iam_role.eks_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Determine role ARN
locals {
  role_arn = var.eks_role_arn != "" ? var.eks_role_arn : aws_iam_role.eks_role[0].arn
}

# Create EKS cluster
resource "aws_eks_cluster" "k8s_cluster" {
  name     = var.cluster_name
  role_arn = local.role_arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
  }

  # Only depend on the attachment if we created it
  depends_on = aws_iam_role_policy_attachment.eks_policy
}
