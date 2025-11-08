output "cluster_name" {
  value = aws_eks_cluster.k8s_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.k8s_cluster.endpoint
}
