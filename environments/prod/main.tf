terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. Asia (Singapore)
provider "aws" {
  alias  = "asia"
  region = "ap-southeast-1"
}

module "vpc_asia" {
  source      = "../../modules/vpc"
  providers   = { aws = aws.asia }
  vpc_cidr    = var.vpc_cidr_asia
  environment = var.environment
  project     = var.project
  region_name = "asia"
}

module "ec2_asia" {
  source            = "../../modules/ec2"
  providers         = { aws = aws.asia }
  vpc_id            = module.vpc_asia.vpc_id
  subnet_id         = module.vpc_asia.public_subnet_id
  jakarta_office_ip = var.jakarta_office_ip
  instance_type     = var.instance_type
  environment       = var.environment
  project           = var.project
  region_name       = "asia"
  public_key        = var.public_key
  backend_ips       = var.backend_ips
  node_domain       = "rusvpn-asia.linkit360.ai"
}

# 2. North America (N. Virginia)
provider "aws" {
  alias  = "na"
  region = "us-east-1"
}

module "vpc_na" {
  source      = "../../modules/vpc"
  providers   = { aws = aws.na }
  vpc_cidr    = var.vpc_cidr_na
  environment = var.environment
  project     = var.project
  region_name = "na"
}

module "ec2_na" {
  source            = "../../modules/ec2"
  providers         = { aws = aws.na }
  vpc_id            = module.vpc_na.vpc_id
  subnet_id         = module.vpc_na.public_subnet_id
  jakarta_office_ip = var.jakarta_office_ip
  instance_type     = var.instance_type
  environment       = var.environment
  project           = var.project
  region_name       = "na"
  public_key        = var.public_key
  backend_ips       = var.backend_ips
  node_domain       = "rusvpn-na.linkit360.ai"
}

# 3. Europe (Frankfurt)
provider "aws" {
  alias  = "eu"
  region = "eu-central-1"
}

module "vpc_eu" {
  source      = "../../modules/vpc"
  providers   = { aws = aws.eu }
  vpc_cidr    = var.vpc_cidr_eu
  environment = var.environment
  project     = var.project
  region_name = "eu"
}

module "ec2_eu" {
  source            = "../../modules/ec2"
  providers         = { aws = aws.eu }
  vpc_id            = module.vpc_eu.vpc_id
  subnet_id         = module.vpc_eu.public_subnet_id
  jakarta_office_ip = var.jakarta_office_ip
  instance_type     = var.instance_type
  environment       = var.environment
  project           = var.project
  region_name       = "eu"
  public_key        = var.public_key
  backend_ips       = var.backend_ips
  node_domain       = "rusvpn-eu.linkit360.ai"
}

# 4. South America (São Paulo)
provider "aws" {
  alias  = "sa"
  region = "sa-east-1"
}

module "vpc_sa" {
  source      = "../../modules/vpc"
  providers   = { aws = aws.sa }
  vpc_cidr    = var.vpc_cidr_sa
  environment = var.environment
  project     = var.project
  region_name = "sa"
}

module "ec2_sa" {
  source            = "../../modules/ec2"
  providers         = { aws = aws.sa }
  vpc_id            = module.vpc_sa.vpc_id
  subnet_id         = module.vpc_sa.public_subnet_id
  jakarta_office_ip = var.jakarta_office_ip
  instance_type     = var.instance_type
  environment       = var.environment
  project           = var.project
  region_name       = "sa"
  public_key        = var.public_key
  backend_ips       = var.backend_ips
  node_domain       = "rusvpn-sa.linkit360.ai"
}

# 5. Australia (Sydney)
provider "aws" {
  alias  = "aus"
  region = "ap-southeast-2"
}

module "vpc_aus" {
  source      = "../../modules/vpc"
  providers   = { aws = aws.aus }
  vpc_cidr    = var.vpc_cidr_aus
  environment = var.environment
  project     = var.project
  region_name = "aus"
}

module "ec2_aus" {
  source            = "../../modules/ec2"
  providers         = { aws = aws.aus }
  vpc_id            = module.vpc_aus.vpc_id
  subnet_id         = module.vpc_aus.public_subnet_id
  jakarta_office_ip = var.jakarta_office_ip
  instance_type     = var.instance_type
  environment       = var.environment
  project           = var.project
  region_name       = "aus"
  public_key        = var.public_key
  backend_ips       = var.backend_ips
  node_domain       = "rusvpn-aus.linkit360.ai"
}
