variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
}

variable "cloudflare_zone" {
  type        = string
  description = "Domain name (NS must be connected), for example elasticscale.io"
}