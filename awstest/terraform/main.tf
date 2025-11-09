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

# Create EC2 instance
resource "aws_instance" "k3s_server" {
  ami           = "ami-0c02fb55956c7d316"  # Ubuntu 22.04
  instance_type = "t2.micro"
  
  tags = {
    Name = "k3s-server"
  }
}

# Output the public IP
output "server_ip" {
  value = aws_instance.k3s_server.public_ip
}