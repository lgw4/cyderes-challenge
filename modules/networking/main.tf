data "aws_availability_zones" "avaliable" {}

module "vpc" {
  source                           = "terraform-aws-modules/vpc/aws"
  version                          = "2.5.0"
  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"
  azs                              = data.aws_availability_zones.avaliable.names
  private_subnets                  = [var.private_subnet]
  public_subnets                   = [var.public_subnet]
  assign_generated_ipv6_cidr_block = true
  enable_nat_gateway               = true
  single_nat_gateway               = true
}

module "lb_sg" {
  source = "scottwinkler/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

module "es_sg" {
  source = "scottwinkler/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [{
    cidr_blocks = [var.private_subnet, var.public_subnet]
  }]
}
