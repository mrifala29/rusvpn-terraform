variable "jakarta_office_ip" {
  description = "IP address of the Jakarta office for SSH whitelisting (CIDR format)"
  type        = string
  default     = "0.0.0.0/0"
}


variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment name (e.g., prod)"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "rusvpn"
}

variable "vpc_cidr_asia" {
  type    = string
  default = "10.10.0.0/16"
}

variable "vpc_cidr_na" {
  type    = string
  default = "10.11.0.0/16"
}

variable "vpc_cidr_eu" {
  type    = string
  default = "10.12.0.0/16"
}

variable "vpc_cidr_sa" {
  type    = string
  default = "10.13.0.0/16"
}

variable "vpc_cidr_aus" {
  type    = string
  default = "10.14.0.0/16"
}

variable "public_key" {
  description = "SSH public key content for all EC2 instances"
  type        = string
}
