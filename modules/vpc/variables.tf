variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
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
