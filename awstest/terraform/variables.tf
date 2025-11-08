variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "mykubernetes"
}

variable "eks_role_arn" {
  default = "arn:aws:iam::624037120855:role/c180773a4650446l12557190t1w624037-LabEksClusterRole-rp3eprhLxjnh"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
