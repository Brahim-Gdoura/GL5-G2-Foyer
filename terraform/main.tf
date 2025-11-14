provider "aws" {
  region = var.aws_region
}

# -----------------------------
# 1️⃣ Création du VPC
# -----------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# -----------------------------
# 2️⃣ Création du cluster EKS
# -----------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.18.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id  = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth = true

  eks_managed_node_groups = {
    default = {
      min_size     = var.min_capacity
      max_size     = var.max_capacity
      desired_size = var.desired_capacity
      instance_types = [var.instance_type]
    }
  }

  tags = {
    Environment = "dev"
    Project     = var.cluster_name
  }
}

# -----------------------------
# 3️⃣ Création du repository ECR
# -----------------------------
resource "aws_ecr_repository" "app" {
  name                 = "${var.cluster_name}-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Environment = "dev"
    Project     = var.cluster_name
  }
}
