module "networking" {
  source         = "./modules/networking"
  namespace      = var.namespace
  private_subnet = var.private_subnet
  public_subnet  = var.public_subnet
}

module "elasticsearch" {
  source    = "./modules/elasticsearch"
  namespace = var.namespace
  region    = var.region
  vpc       = module.networking.vpc
  sg        = module.networking.sg
}

module "ecs" {
  source      = "./modules/ecs"
  namespace   = var.namespace
  nginx_image = var.nginx_image
  vpc         = module.networking.vpc
  sg          = module.networking.sg
}
