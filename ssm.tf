resource "aws_ssm_parameter" "tunneltoken" {
  name  = "${var.prefix}-tunneltoken"
  type  = "SecureString"
  value = cloudflare_tunnel.tunnel.tunnel_token
}
