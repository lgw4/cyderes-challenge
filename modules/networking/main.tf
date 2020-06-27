data "aws_availability_zones" "avaliable" {}

module "vpc" {
  source                           = "terraform-aws-modules/vpc/aws"
  version                          = "2.5.0"
  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"
  azs                              = data.aws_availability_zones.avaliable.names
  private_subnets                  = ["10.0.1.0/24"]
  public_subnets                   = ["10.0.101.0/24"]
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
