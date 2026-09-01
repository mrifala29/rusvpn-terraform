output "public_ip" {
  description = "The public IP address (EIP) of the VPN node"
  value       = aws_eip.vpn.public_ip
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.vpn.id
}

output "agent_token" {
  description = "The token for the provisioning agent"
  value       = random_password.agent_token.result
  sensitive   = true
}
