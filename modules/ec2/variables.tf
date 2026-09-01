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
  type = string
}

variable "backend_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
