variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "mykubernetes"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# ARN of a pre-existing IAM role for EKS (provided by AWS Academy lab)
variable "eks_role_arn" {
  description = "Pre-existing IAM role ARN for EKS"
  type        = string
}
