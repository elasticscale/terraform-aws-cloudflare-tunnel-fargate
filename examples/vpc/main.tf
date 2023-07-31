provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_providers {
    cloudflare = {
      source  = "registry.terraform.io/cloudflare/cloudflare"
      version = "4.0.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "tunnel" {
  source                  = "../../"
  docker_hub_username     = var.docker_hub_username
  docker_hub_access_token = var.docker_hub_access_token
  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  cloudflare_zone         = var.cloudflare_zone
  cloudflare_account_id = var.cloudflare_account_id
}

// supporting resources

resource "aws_eip" "nat" {
  count  = 3
  domain = "vpc"
}

module "vpc" {
  source              = "terraform-aws-modules/vpc/aws"
  version             = "5.1.0"
  name                = "cloudflare-vpc"
  cidr                = "10.0.0.0/16"
  azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway  = true
  single_nat_gateway  = false
  enable_vpn_gateway  = false
  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id
}