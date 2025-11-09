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

  # NodePort range for K3s
  ingress {
    description = "NodePort Services"
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
  key_name               = var.key_pair_name

  # Disk minimal (30 GB free tier)
  root_block_device {
    volume_size = 20  # GB
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-k3s-master"
    Type = "K3s-Master"
  }
}

# Data source pour availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Outputs
output "k3s_master_public_ip" {
  description = "Public IP of K3s master instance"
  value       = aws_instance.k3s_master.public_ip
}

output "k3s_master_private_ip" {
  description = "Private IP of K3s master instance"
  value       = aws_instance.k3s_master.private_ip
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_instance.k3s_master.public_ip}"
}

output "kubeconfig_info" {
  description = "Info about kubeconfig"
  value       = "Kubeconfig is available at /home/ubuntu/.kube/config on the instance"
}