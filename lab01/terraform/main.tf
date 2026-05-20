# Latest Amazon Linux 2 AMI (used when ami_id is empty)
data "aws_ami" "amazon_linux_2" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2[0].id
}

module "vpc" {
  source      = "./modules/vpc"
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "subnet" {
  source              = "./modules/subnet"
  name_prefix         = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}

module "internet_gateway" {
  source      = "./modules/internet_gateway"
  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id
}

module "nat_gateway" {
  source           = "./modules/nat_gateway"
  name_prefix      = var.name_prefix
  public_subnet_id = module.subnet.public_subnet_id
  depends_on       = [module.internet_gateway]
}

module "route_table" {
  source              = "./modules/route_table"
  name_prefix         = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_id    = module.subnet.public_subnet_id
  private_subnet_id   = module.subnet.private_subnet_id
}

module "security_group" {
  source      = "./modules/security_group"
  name_prefix = var.name_prefix
  vpc_id      = module.vpc.vpc_id
  my_ip       = var.my_ip
}

module "ec2" {
  source             = "./modules/ec2"
  name_prefix        = var.name_prefix
  ami_id             = local.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  public_subnet_id   = module.subnet.public_subnet_id
  private_subnet_id  = module.subnet.private_subnet_id
  public_sg_id       = module.security_group.public_sg_id
  private_sg_id      = module.security_group.private_sg_id
}
