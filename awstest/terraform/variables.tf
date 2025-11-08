variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "mykubernetes"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# If you want to use a pre-existing IAM role, set this
variable "eks_role_arn" {
  description = "ARN of existing IAM role for EKS cluster"
  default     = ""  # leave empty if Terraform should create a new role
}
