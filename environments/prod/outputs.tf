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
