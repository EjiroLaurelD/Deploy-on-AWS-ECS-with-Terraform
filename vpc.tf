module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs  = var.vpc_azs
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets

  create_igw             = true
  enable_nat_gateway     = true
  create_egress_only_igw = true
  single_nat_gateway     = true
}
