## Description

ss

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >=4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.0.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >=4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.executionrole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.tunnel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.tunneltoken](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| cloudflare_tunnel.tunnel | resource |
| cloudflare_tunnel_config.config | resource |
| cloudflare_tunnel_route.route | resource |
| [random_password.tunnel_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| cloudflare_zone.zone | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_account_id"></a> [cloudflare\_account\_id](#input\_cloudflare\_account\_id) | Cloudflare account ID | `string` | n/a | yes |
| <a name="input_cloudflare_version"></a> [cloudflare\_version](#input\_cloudflare\_version) | Cloudflare version to use, defaults to latest but best to pick a docker tag version to prevent issues | `string` | `"latest"` | no |
| <a name="input_cloudflare_zone"></a> [cloudflare\_zone](#input\_cloudflare\_zone) | Domain name (NS must be connected and verified in Cloudflare) | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU units to allocate to each instance, defaults to 256, needs to be within Fargate configuration limits | `number` | `256` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances to run initially, choose 3 or more for high availability across AZs | `number` | `3` | no |
| <a name="input_fargate_type"></a> [fargate\_type](#input\_fargate\_type) | Use spot instances or regular instances (FARGATE\_SPOT or FARGATE), SPOT is much cheaper and does not really affect availability in this case | `string` | `"FARGATE_SPOT"` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules to allow traffic to (see cloudflare\_tunnel\_config docs, access\_block not supported right now) | <pre>list(object({<br>    hostname = optional(string)<br>    path     = optional(string)<br>    service  = string<br>  }))</pre> | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory units to allocate to each instance, defaults to 512, needs to be within Fargate configuration limits | `number` | `512` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to add to all resources | `string` | `"cf-tunnel"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets to launch the Cloudflare instances in (must be same VPC under VPC ID) | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_tunnel_cname"></a> [tunnel\_cname](#output\_tunnel\_cname) | The CNAME of the Cloudflare Tunnel (you can add this as a CNAME in the DNS settings to route traffic to the tunnel, which will be processed by the rules) |
| <a name="output_tunnel_id"></a> [tunnel\_id](#output\_tunnel\_id) | The ID of the Cloudflare Tunnel |
