provider "aws" {
  region = var.aws_region
}

module "net" {
  source = "./modules/net"
  
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id          = module.net.vpc_id
  public_subnets  = module.net.public_subnet_ids
  private_subnets = module.net.private_subnet_ids
  ami_id          = "ami-006ec002b74f6c066"
}


// ... 기존 코드 ...

module "db" {
  source = "./modules/db"
  
  vpc_id                = module.net.vpc_id
  private_subnets       = module.net.private_subnet_ids
  web_security_group_id = module.ec2.web_security_group_id
  db_password          = var.db_password
}