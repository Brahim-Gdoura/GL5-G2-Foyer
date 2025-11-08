# Get availability zones
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  tags = { Name = "eks-vpc" }
}

# Create public subnets
resource "aws_subnet" "eks_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "eks-public-${count.index + 1}" }
}

# Use pre-existing IAM role (no creation)
# variable "eks_role_arn" will hold the ARN
# Create EKS cluster
resource "aws_eks_cluster" "k8s_cluster" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
  }
}
