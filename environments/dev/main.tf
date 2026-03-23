module "networking" {
  source = "../../modules/networking"

  project_name           = "buddy-athletics"
  environment            = "dev"
  vpc_cidr               = "10.0.0.0/16"
  public_subnet_count    = 2
  enable_private_subnets = false
}
