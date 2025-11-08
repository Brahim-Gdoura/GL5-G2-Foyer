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

# Utiliser des ressources simples qui fonctionnent avec la plupart des comptes
locals {
  # AMI Ubuntu 22.04 LTS pour us-east-1 (la plus commune)
  ubuntu_ami = "ami-053b0d53c279acc90"
  
  # Zone de disponibilité simple
  availability_zone = "${var.aws_region}a"
}

# VPC simple
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "k3s-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "k3s-igw"
  }
}

# Subnet public simple
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "k3s-public-subnet"
  }
}

# Route table simple
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "k3s-public-rt"
  }
}

# Association route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group simplifié
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-sg"
  description = "Security group for K3s"
  vpc_id      = aws_vpc.main.id

  # SSH seulement depuis votre IP (plus sécurisé)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Pour tester, après restreindre à votre IP
  }

  # HTTP/HTTPS pour les applications
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tout le trafic sortant autorisé
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}

# Instance EC2 simple
resource "aws_instance" "k3s_server" {
  ami           = local.ubuntu_ami
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  
  # Pas de clé SSH pour simplifier (vous pouvez ajouter plus tard)
  # key_name      = aws_key_pair.k3s_key.key_name
  
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  # Disk de base
  root_block_device {
    volume_size = 8  # Minimum pour Ubuntu
    volume_type = "gp2"
  }

  # Script d'installation simplifié
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl
              curl -sfL https://get.k3s.io | sh -
              echo "K3s installed successfully!"
              EOF

  tags = {
    Name = "k3s-server"
  }
}

# IP Elastic simple
resource "aws_eip" "k3s_ip" {
  instance = aws_instance.k3s_server.id
  domain   = "vpc"
  
  tags = {
    Name = "k3s-ip"
  }
}
