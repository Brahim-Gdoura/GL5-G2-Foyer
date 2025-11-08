output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}

output "ec2_instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.bastion.id
}

output "ec2_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.bastion.public_ip
}

output "eks_cluster_name" {
  description = "Nom du cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group du cluster EKS"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "configure_kubectl" {
  description = "Commande pour configurer kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
