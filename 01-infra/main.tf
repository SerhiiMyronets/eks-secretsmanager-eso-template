module "vpc" {
  source = "./modules/01-vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cluster_name         = var.cluster_name
}

module "eks" {
  source = "./modules/02-eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnet_ids
  node_groups     = var.node_groups_config
}

module "rds" {
  source = "./modules/03-rds"

  cluster_name         = var.cluster_name
  private_subnet_cidrs = var.private_subnet_cidrs
  rds_config           = var.rds_config
  db_subnet_ids        = module.vpc.private_subnet_ids
  vpc_id               = module.vpc.vpc_id
}


module "irsa" {
  source            = "./modules/04-irsa"
  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  secret_arns       = module.rds.db_credential_arns
}