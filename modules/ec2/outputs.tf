output "public_ip" {
  description = "The public IP address (EIP) of the VPN node"
  value       = aws_eip.vpn.public_ip
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.vpn.id
}

output "private_key_pem" {
  description = "The generated private key for SSH access"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

