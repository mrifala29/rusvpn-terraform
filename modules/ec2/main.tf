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

  tags = {
    Name        = "${var.project}-${var.environment}-${var.region_name}-key"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "RND-Rival"
  }
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
  # Provisioning Agent
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = var.backend_ips
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

  user_data = <<-EOF
#!/bin/bash
export ENVIRONMENT="${var.environment}"
export REGION_NAME="${var.region_name}"
export AGENT_TOKEN="${random_password.agent_token.result}"

${replace(file("${path.module}/user_data.sh"), "#!/bin/bash\n", "")}
EOF

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Enforce IMDSv2
  }

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

resource "random_password" "agent_token" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "agent_token" {
  name  = "/rusvpn/${var.environment}/${var.region_name}/agent-token"
  type  = "SecureString"
  value = random_password.agent_token.result

  tags = {
    Name        = "${var.project}-${var.environment}-${var.region_name}-agent-token"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "RND-Rival"
  }
}

resource "aws_ebs_volume" "pki" {
  availability_zone = aws_instance.vpn.availability_zone
  size              = 1
  type              = "gp3"

  tags = {
    Name        = "${var.project}-${var.environment}-${var.region_name}-pki-volume"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "RND-Rival"
  }
}

resource "aws_volume_attachment" "pki" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.pki.id
  instance_id = aws_instance.vpn.id
}
