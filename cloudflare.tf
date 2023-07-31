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
  # config_src = "local"
}

resource "cloudflare_tunnel_route" "route" {
    account_id = var.cloudflare_account_id
    tunnel_id = cloudflare_tunnel.tunnel.id
    network = data.aws_vpc.vpc.cidr_block
    comment = "Tunnel route for ${var.vpc_id}"
}

resource "cloudflare_tunnel_config" "config" {
  account_id = data.cloudflare_zone.zone.account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id
  config {
    warp_routing {
      enabled = true
    }
    ingress_rule {
      hostname = "foo"
      path     = "/bar"
      service  = "http://10.0.0.2:8080"
    }
    ingress_rule {
      service = "https://10.0.0.3:8081"
    }
  }
}