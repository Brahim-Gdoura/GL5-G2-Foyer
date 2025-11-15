terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # ✅ Spécifier la version du provider
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

# --- VPC ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"  # ✅ Version compatible

  name = "simple-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Tags pour EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/simple-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/simple-eks" = "shared"
  }
}

# --- EKS ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"  # ✅ Version stable et compatible

  cluster_name    = "simple-eks"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Accès public au cluster
  cluster_endpoint_public_access = true

  # Configuration des node groups
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      # Ajouter les tags nécessaires
      tags = {
        Environment = "dev"
      }
    }
  }

  # Tags du cluster
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}