output "connect_command" {
  value = "ssh ubuntu@${aws_instance.k3s_server.public_ip}"
}