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

variable "cloudflare_zone" {
  type        = string
  description = "Domain name (NS must be connected)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets to launch the Vault Cluster in (must be in the same VPC)"
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all resources"
  default     = "cf-tunnel"
}


