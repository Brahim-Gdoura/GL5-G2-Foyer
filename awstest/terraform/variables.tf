variable "aws_region" {
  description = "Région AWS où déployer les ressources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "tp-k8s-demo"
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Type d'instance EC2 (free tier)"
  type        = string
  default     = "t2.micro"  # Free tier eligible
}

variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
  default     = "demo-eks-cluster"
}

variable "desired_capacity" {
  description = "Nombre de nodes dans le cluster"
  type        = number
  default     = 1  # Minimum pour économiser
}

variable "max_capacity" {
  description = "Nombre maximum de nodes"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Nombre minimum de nodes"
  type        = number
  default     = 1
}
