terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC
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

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "k3s-public-subnet"
  }
}

# Route Table
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

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-sg"
  description = "Security group for K3s cluster"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K3s API
  ingress {
    description = "K3s API"
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

  # NodePort range
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
    Name = "k3s-sg"
  }
}

# Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# K3s Master Instance
resource "aws_instance" "k3s_master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"  # Upgraded for K3s
  subnet_id     = aws_subnet.public.id
  
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  key_name               = "my-key-pair"  # Update with your key pair name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # K3s installation script
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              apt-get update
              apt-get upgrade -y
              
              # Install K3s
              curl -sfL https://get.k3s.io | sh -
              
              # Wait for K3s to start
              sleep 60
              
              # Create demo namespace
              /usr/local/bin/kubectl create namespace demo --kubeconfig /etc/rancher/k3s/k3s.yaml || true
              
              # Deploy NGINX
              /usr/local/bin/kubectl create deployment nginx --image=nginx:alpine --namespace=demo --kubeconfig /etc/rancher/k3s/k3s.yaml
              /usr/local/bin/kubectl expose deployment nginx --port=80 --type=NodePort --namespace=demo --kubeconfig /etc/rancher/k3s/k3s.yaml
              
              # Setup kubeconfig for ubuntu user
              mkdir -p /home/ubuntu/.kube
              cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
              chown -R ubuntu:ubuntu /home/ubuntu/.kube
              chmod 600 /home/ubuntu/.kube/config
              
              # Update kubeconfig with public IP
              IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              sed -i "s/127.0.0.1/$IP/g" /home/ubuntu/.kube/config
              
              echo "K3s installed successfully!" > /home/ubuntu/k3s-info.txt
              echo "Public IP: $IP" >> /home/ubuntu/k3s-info.txt
              echo "NGINX NodePort: check with 'kubectl get svc -n demo nginx'" >> /home/ubuntu/k3s-info.txt
              EOF

  tags = {
    Name = "k3s-master"
  }
}

# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Outputs
output "k3s_master_public_ip" {
  description = "Public IP of K3s master"
  value       = aws_instance.k3s_master.public_ip
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i my-key-pair.pem ubuntu@${aws_instance.k3s_master.public_ip}"
}

output "kubeconfig_info" {
  description = "Kubeconfig location"
  value       = "Kubeconfig: /home/ubuntu/.kube/config on the instance"
}

output "nginx_access" {
  description = "How to access NGINX"
  value       = "Get NodePort: kubectl get svc -n demo nginx --kubeconfig /home/ubuntu/.kube/config"
}