output "k3s_master_public_ip" {
  description = "Adresse IP publique du master K3s"
  value       = aws_eip.k3s_ip.public_ip
}

output "k3s_master_instance_id" {
  description = "ID de l'instance K3s master"
  value       = aws_instance.k3s_master.id
}

output "ssh_connection_command" {
  description = "Commande pour se connecter en SSH"
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_eip.k3s_ip.public_ip}"
}

output "k3s_info" {
  description = "Informations de connexion K3s"
  value = <<EOT
K3s Cluster installé avec succès!

Pour vous connecter:
1. SSH: ssh -i ${var.key_name}.pem ubuntu@${aws_eip.k3s_ip.public_ip}
2. Vérifier le cluster: sudo kubectl get nodes
3. Vérifier les pods: sudo kubectl get pods -A

Applications déployées:
- Namespace 'demo' créé
- Déploiement nginx dans le namespace demo

Pour accéder à l'application nginx:
kubectl port-forward -n demo deployment/nginx 8080:80
Puis ouvrir http://localhost:8080
EOT
}

output "kubeconfig_instructions" {
  description = "Instructions pour récupérer le kubeconfig"
  value = <<EOT
Pour récupérer le kubeconfig:
1. scp -i ${var.key_name}.pem ubuntu@${aws_eip.k3s_ip.public_ip}:/etc/rancher/k3s/k3s.yaml ./k3s-config.yaml
2. Modifier le fichier: remplacer '127.0.0.1' par '${aws_eip.k3s_ip.public_ip}'
3. Exporter: export KUBECONFIG=./k3s-config.yaml
4. Tester: kubectl get nodes
EOT
}

output "security_group_id" {
  description = "ID du security group K3s"
  value       = aws_security_group.k3s_sg.id
}

output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}
