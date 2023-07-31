terraform {
  required_providers {
    // todo, pin >=
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.0"
    }
    cloudflare = {
      source  = "registry.terraform.io/cloudflare/cloudflare"
      version = "4.0.0"
    }
  }
}