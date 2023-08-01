variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "cloudflare_zone" {
  type        = string
  description = "Domain name (NS must be connected and verified in Cloudflare)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets to launch the Cloudflare instances in (must be same VPC under VPC ID)"
}

variable "ingress_rules" {
  type = list(object({
    hostname = optional(string)
    path     = optional(string)
    service  = string
  }))
  description = "List of ingress rules to allow traffic to (see cloudflare_tunnel_config docs, access_block not supported right now)"
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all resources"
  default     = "cf-tunnel"
}

variable "desired_count" {
  type        = number
  description = "Number of instances to run initially, choose 3 or more for high availability across AZs"
  default     = 3
}

variable "fargate_type" {
  type        = string
  description = "Use spot instances or regular instances (FARGATE_SPOT or FARGATE), SPOT is much cheaper and does not really affect availability in this case"
  validation {
    condition     = length(regexall("^(FARGATE_SPOT|FARGATE)$", var.fargate_type)) > 0
    error_message = "ERROR: Valid types are \"FARGATE_SPOT\" and \"FARGATE\"!"
  }
  default = "FARGATE_SPOT"
}

variable "cloudflare_version" {
  type        = string
  description = "Cloudflare version to use, defaults to latest but best to pick a docker tag version to prevent issues"
  default     = "latest"
}

variable "cpu" {
  type        = number
  description = "CPU units to allocate to each instance, defaults to 256, needs to be within Fargate configuration limits"
  default     = 256
}

variable "memory" {
  type        = number
  description = "Memory units to allocate to each instance, defaults to 512, needs to be within Fargate configuration limits"
  default     = 512
}