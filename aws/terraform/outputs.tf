output "k3s_master_public_ip" {
  description = "Public IP address of the K3s master node"
  value       = aws_instance.k3s_master.public_ip
}

output "k3s_master_private_ip" {
  description = "Private IP address of the K3s master node"
  value       = aws_instance.k3s_master.private_ip
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_instance.k3s_master.public_ip}"
}

output "k3s_access_url" {
  description = "K3s API server URL"
  value       = "https://${aws_instance.k3s_master.public_ip}:6443"
}

output "application_url" {
  description = "Application access URL"
  value       = "http://${aws_instance.k3s_master.public_ip}:30083/tpFoyer17"
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig"
  value       = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_instance.k3s_master.public_ip} 'cat ~/.kube/config'"
}
