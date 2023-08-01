output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.tunnel.id
}

output "tunnel_id" {
  description = "The ID of the Cloudflare Tunnel"
  value       = cloudflare_tunnel.tunnel.id
}

output "tunnel_cname" {
  description = "The CNAME of the Cloudflare Tunnel (you can add this as a CNAME in the DNS settings to route traffic to the tunnel, which will be processed by the rules)"
  value       = cloudflare_tunnel.tunnel.cname
}