terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "vpn" {
  key_name   = "${var.project}-${var.environment}-${var.region_name}-key"
  public_key = var.public_key
}

resource "aws_security_group" "vpn" {
  name        = "${var.project}-${var.environment}-${var.region_name}-vpn-sg"
  description = "Security group for VPN Node"
  vpc_id      = var.vpc_id

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.jakarta_office_ip]
  }

  # OpenVPN UDP
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.region_name}-vpn-sg"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "RND-Rival"
  }
}

resource "aws_instance" "vpn" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.vpn.key_name
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.vpn.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name        = "${var.project}-${var.environment}-${var.region_name}-vpn-node"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "RND-Rival"
  }
}

resource "aws_eip" "vpn" {
  instance = aws_instance.vpn.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.region_name}-eip"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "RND-Rival"
  }
}
