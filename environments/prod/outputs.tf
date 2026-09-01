output "vpn_ip_asia" {
  description = "Public IP for Asia (Singapore)"
  value       = module.ec2_asia.public_ip
}

output "vpn_ip_na" {
  description = "Public IP for North America (N. Virginia)"
  value       = module.ec2_na.public_ip
}

output "vpn_ip_eu" {
  description = "Public IP for Europe (Frankfurt)"
  value       = module.ec2_eu.public_ip
}

output "vpn_ip_sa" {
  description = "Public IP for South America (São Paulo)"
  value       = module.ec2_sa.public_ip
}

output "vpn_ip_aus" {
  description = "Public IP for Australia (Sydney)"
  value       = module.ec2_aus.public_ip
}

output "vpn_token_asia" {
  description = "Agent token for Asia"
  value       = module.ec2_asia.agent_token
  sensitive   = true
}

output "vpn_token_na" {
  description = "Agent token for North America"
  value       = module.ec2_na.agent_token
  sensitive   = true
}

output "vpn_token_eu" {
  description = "Agent token for Europe"
  value       = module.ec2_eu.agent_token
  sensitive   = true
}

output "vpn_token_sa" {
  description = "Agent token for South America"
  value       = module.ec2_sa.agent_token
  sensitive   = true
}

output "vpn_token_aus" {
  description = "Agent token for Australia"
  value       = module.ec2_aus.agent_token
  sensitive   = true
}
