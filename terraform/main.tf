terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

# Data source pour les AZs disponibles
data "aws_availability_zones" "available" {
  state = "available"
}

# --- VPC ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "simple-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags pour EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/cluster/simple-eks"    = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/simple-eks"    = "shared"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# --- EKS Cluster ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"  # ✅ Version la plus récente

  cluster_name    = "simple-eks"
  cluster_version = "1.28"

  # Configuration réseau
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  control_plane_subnet_ids        = module.vpc.private_subnets

  # Accès au cluster
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Addons EKS (optionnel)
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Node Groups
  eks_managed_node_groups = {
    default = {
      name = "simple-node-group"

      # Capacité
      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Type d'instance
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      # Disque
      disk_size = 20

      # Mise à jour
      update_config = {
        max_unavailable_percentage = 50
      }

      # Tags
      tags = {
        Environment = "dev"
        NodeGroup   = "default"
      }
    }
  }

  # Tags du cluster
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}