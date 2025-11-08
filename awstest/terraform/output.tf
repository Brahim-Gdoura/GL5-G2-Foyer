# outputs.tf
output "k3s_server_public_ip" {
  description = "Adresse IP publique du serveur K3s"
  value       = aws_eip.k3s_ip.public_ip
}

output "k3s_server_instance_id" {
  description = "ID de l'instance K3s server"
  value       = aws_instance.k3s_server.id
}

output "ssh_connection_command" {
  description = "Commande pour se connecter en SSH"
  value       = "ssh ubuntu@${aws_eip.k3s_ip.public_ip}"
}

output "k3s_info" {
  description = "Informations de connexion K3s"
  value = <<EOT
K3s Cluster déployé avec Jenkins!

Pour vous connecter:
1. SSH: ssh ubuntu@${aws_eip.k3s_ip.public_ip}
2. Vérifier K3s: sudo kubectl get nodes

Accès aux applications:
- Ports 30000-32767 ouverts pour NodePort
EOT
}

