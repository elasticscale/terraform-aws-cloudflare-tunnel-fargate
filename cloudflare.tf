data "cloudflare_zone" "zone" {
  name = var.cloudflare_zone
}

resource "random_password" "tunnel_secret" {
  length = 64
}

resource "random_string" "suffix" {
  length  = 16
  special = false
  upper   = false
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = data.cloudflare_zone.zone.account_id
  name       = "${var.prefix}-tunnel-${random_string.suffix.result}"
  secret     = base64encode(random_password.tunnel_secret.result)
}

resource "cloudflare_tunnel_route" "route" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id
  network    = data.aws_vpc.vpc.cidr_block
  comment    = "Tunnel route for ${var.vpc_id}"
}

resource "cloudflare_tunnel_config" "config" {
  account_id = data.cloudflare_zone.zone.account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id
  config {
    warp_routing {
      enabled = true
    }
    dynamic "ingress_rule" {
      for_each = var.ingress_rules
      content {
        hostname = ingress_rule.value.hostname
        path     = ingress_rule.value.path
        service  = ingress_rule.value.service
      }
    }
  }
}