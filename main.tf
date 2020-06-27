module "networking" {
  source         = "./modules/networking"
  namespace      = var.namespace
  private_subnet = var.private_subnet
  public_subnet  = var.public_subnet
}

module "elasticsearch" {
  source    = "./modules/elasticsearch"
  namespace = var.namespace
  vpc       = module.networking.vpc
  sg        = module.networking.sg
}
