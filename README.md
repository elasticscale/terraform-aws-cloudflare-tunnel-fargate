## Description

This is a very easy way to get cheap access to all resources in your VPC.

The exact costs depend on if you use Fargate Spot (default option) and the number of instances (and their size).

* For 1 spot instance of the smallest type: 2.66 USD per month
* For 3 spot instances of the smallest type: 8.00 USD per month

You can use spot instances just fine if the desired_count > 1.

The steps you need to take:

1. Create a Cloudflare account (a free account will do)
2. Setup a cloudflare domain and connect the nameservers and wait until it is verified. After deploying you can click on the domain and find the Account ID.
3. Create a Zero Trust team account (the free account will do)
4. [Create a custom API token](https://dash.cloudflare.com/profile/api-tokens), with these permissions:
    * Account/Cloudflare Tunnel/Edit
    * Account/Zero Trust/Edit
    * Zone/Zone/Read
5. Deploy this module

These are one time steps and only need to be executed one time in a Zero Trust account:

6. Go to Zero Trust settings > WARP client > Device enrollment permissions and add a rule, for instance you can auth to Warp if your email ends at elasticscale.cloud
7. Go to Zero Trust settings > WARP Client > Edit the default profile, go the Split Tunnels section and click Manage, remove the CIDR block 10.0.0.0/8 (or if your VPC has another CIDR block that overlaps with one here, remove that one)
8. [Install the WARP client](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/download-warp/), then go to preferences, Account and click Login to Cloudflare Zero trust

After you connect to the WARP agent and whitelist the security group of this module to the instances you want to connect to, you should be able to connect to the instances via their private IPs.

You can also use this module to give Zero Trust access to internal load balancers or other services. You need to then set the ingress rules and add a CNAME to the Cloudflare domain.

[For more debugging steps check out the elasticscale blog.](https://elasticscale.cloud/en/get-a-free-vpn-into-your-aws-vpc-and-worldwide-performance-improvement-through-cloudflare-tunnels/)

## About ElasticScale

ElasticScale is a Solutions Architecture as a Service focusing on start-ups and scale-ups. For a fixed monthly subscription fee, we handle all your AWS workloads. Some services include:

* Migrating **existing workloads** to AWS
* Implementing the **Zero Trust security model**
* Integrating **DevOps principles** within your organization
* Moving to **infrastructure automation** (Terraform)
* Complying with **ISO27001 regulations within AWS**

You can **pause** the subscription at any time and have **direct access** to certified AWS professionals.

Check out our <a href="https://elasticscale.cloud" target="_blank" style="color: #14dcc0; text-decoration: underline">website</a> for more information.

<img src="https://static.elasticscale.io/logo/square/elasticscale_logo_transparent.png" alt="ElasticScale logo" width="150"/>

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
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules to allow traffic to (see cloudflare\_tunnel\_config docs, access\_block not supported right now) | <pre>list(object({<br>    hostname = optional(string)<br>    path     = optional(string)<br>    service  = string<br>  }))</pre> | <pre>[<br>  {<br>    "service": "http_status:404"<br>  }<br>]</pre> | no |
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
