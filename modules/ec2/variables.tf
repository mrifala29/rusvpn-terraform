variable "vpc_id" {
  description = "VPC ID where the EC2 will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 will be deployed"
  type        = string
}

variable "jakarta_office_ip" {
  description = "IP address of the Jakarta office for SSH whitelisting (CIDR format)"
  type        = string
}


variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name (e.g., prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "rusvpn"
}

variable "region_name" {
  description = "Name alias for the region (e.g., asia, europe)"
  type        = string
}

variable "public_key" {
  description = "SSH public key content to inject into EC2 instances"
  type        = string
}
