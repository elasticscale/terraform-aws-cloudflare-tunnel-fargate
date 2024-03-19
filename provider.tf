terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
    cloudflare = {
      source  = "registry.terraform.io/cloudflare/cloudflare"
      version = ">=4.0.0"
    }
  }
}
