terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  # AMI Ubuntu 22.04 LTS pour différentes régions (hardcodées pour éviter les permissions)
  ami_ids = {
    "us-east-1"    = "ami-053b0d53c279acc90" # Virginie du Nord
    "us-east-2"    = "ami-024e6efaf93d85776" # Ohio
    "us-west-1"    = "ami-0aab355d464c15d05" # Californie du Nord
    "us-west-2"    = "ami-0f1a5f5ada0e7da53" # Oregon
    "eu-west-1"    = "ami-0f1a5f5ada0e7da53" # Irlande
    "eu-central-1" = "ami-0faab6bdbac9486fb" # Francfort
  }
  
  # Utiliser la zone de disponibilité 'a' par défaut
  availability_zone = "${var.aws_region}a"
}

# VPC (Gratuit)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway (Gratuit)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 1 seul Subnet public (Gratuit)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Route table (Gratuit)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group (Gratuit)
resource "aws_security_group" "k3s_sg" {
  name        = "${var.project_name}-k3s-sg"
  description = "Security group pour K3s"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K3s node port range
  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-k3s-sg"
  }
}

# Clé SSH
resource "aws_key_pair" "k3s_key" {
  key_name   = var.key_name
  public_key = file("${var.key_name}.pub")
}

# Instance EC2 avec K3s (Free Tier: t2.micro = 750h/mois gratuit)
resource "aws_instance" "k3s_master" {
  ami           = local.ami_ids[var.aws_region]
  instance_type = "t2.micro"  # FREE TIER
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.k3s_key.key_name
  
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  # Disk minimal (30 GB free tier)
  root_block_device {
    volume_size = 20  # GB
    volume_type = "gp3"
    encrypted   = true
  }

  # Script d'installation K3s automatique
  user_data = file("${path.module}/k3s-install.sh")

  tags = {
    Name = "${var.project_name}-k3s-master"
    Type = "K3s-Master"
  }

  # Donner le temps à l'instance de démarrer
  timeouts {
    create = "10m"
    delete = "10m"
  }

  depends_on = [aws_internet_gateway.main]
}

# Elastic IP pour avoir une IP fixe (optionnel)
resource "aws_eip" "k3s_ip" {
  instance = aws_instance.k3s_master.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.project_name}-k3s-ip"
  }
}
