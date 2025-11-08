variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "k3s-free-tier"
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_name" {
  description = "Nom de la clé SSH"
  type        = string
  default     = "k3s-key"
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks autorisés pour l'accès admin"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # À restreindre en production
}
