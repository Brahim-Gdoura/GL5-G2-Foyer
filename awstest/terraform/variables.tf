# variables.tf
variable "project_name" {
  description = "Nom du projet pour le tagging"
  type        = string
  default     = "k3s-jenkins"
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}
