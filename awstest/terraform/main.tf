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
  availability_zone       = data.aws_availability_zones.available.names[0]
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

# AMI Ubuntu (Gratuit)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Instance EC2 avec K3s (Free Tier: t2.micro = 750h/mois gratuit)
resource "aws_instance" "k3s_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"  # FREE TIER
  subnet_id     = aws_subnet.public.id
  
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  # Disk minimal (30 GB free tier)
  root_block_device {
    volume_size = 20  # GB
    volume_type = "gp3"
  }

  # Script d'installation K3s automatique
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Mise à jour du système
              apt-get update
              apt-get upgrade -y
              
              # Installation de K3s (Kubernetes léger)
              curl -sfL https://get.k3s.io | sh -
              
              # Attendre que K3s démarre
              sleep 30
              
              # Créer un namespace de démo
              kubectl create namespace demo
              
              # Déployer une app de test (nginx)
              kubectl create deployment nginx --image=nginx --namespace=demo
              kubectl expose deployment nginx --port=80 --type=NodePort --namespace=demo
              
              # Copier le kubeconfig pour l'utilisateur ubuntu
              mkdir -p /home/ubuntu/.kube
              cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
              chown -R ubuntu:ubuntu /home/ubuntu/.kube
              
              # Afficher le token pour se connecter
              echo "K3s installé avec succès!" > /home/ubuntu/k3s-info.txt
              echo "Token K3s:" >> /home/ubuntu/k3s-info.txt
              cat /var/lib/rancher/k3s/server/node-token >> /home/ubuntu/k3s-info.txt
              
              EOF

  tags = {
    Name = "${var.project_name}-k3s-master"
    Type = "K3s-Master"
  }
}

# Data source pour availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
