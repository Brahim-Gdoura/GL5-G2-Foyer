output "k3s_cluster_info" {
  description = "K3s cluster connection information"
  value = {
    public_ip  = aws_instance.k3s_master.public_ip
    ssh_command = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_instance.k3s_master.public_ip}"
    kubeconfig = "Download kubeconfig from /home/ubuntu/.kube/config on the instance"
  }
}

output "nginx_service_info" {
  description = "NGINX service access information"
  value = {
    node_port = "Check with: kubectl get svc -n demo nginx"
    url       = "http://${aws_instance.k3s_master.public_ip}:30000-32767"
  }
}