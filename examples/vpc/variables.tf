variable "docker_hub_username" {
  type        = string
  description = "Docker Hub username"
}

variable "docker_hub_access_token" {
  type        = string
  description = "Docker Hub access token (public repo read only access)"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "cloudflare_api_token" {
  type  =string 
  description = "Cloudflare API token"
}

variable "cloudflare_zone" {
  type        = string
  description = "Domain name (NS must be connected), for example elasticscale.io"
}