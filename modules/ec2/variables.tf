variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "jakarta_office_ip" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "region_name" {
  type = string
}

variable "public_key" {
  description = "SSH public key content"
  type        = string
}

variable "node_domain" {
  description = "The DNS domain name for this node (e.g., rusvpn-asia.linkit360.ai)"
  type        = string
}

variable "backend_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
