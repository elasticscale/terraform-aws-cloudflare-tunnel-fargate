resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [var.fargate_type]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.fargate_type
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.prefix}-taskdef"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.executionrole.arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions = jsonencode([
    {
      name      = "cloudflared"
      essential = true
      image     = "cloudflare/cloudflared:${var.cloudflare_version}",
      command   = ["tunnel", "run", cloudflare_tunnel.tunnel.id]
      secrets = [
        {
          name      = "TUNNEL_TOKEN",
          valueFrom = aws_ssm_parameter.tunneltoken.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.logs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "cloudflared"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "${var.prefix}-logs"
  retention_in_days = 1
}

resource "aws_security_group" "tunnel" {
  name        = "${var.prefix}-tunnel"
  description = "This is the security group for the Cloudflare tunnel instances"
  vpc_id      = var.vpc_id
  // does not require any ingress ports, just egress
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    // required to either be the VPC CIDR block, or have VPC endpoints for SSM, ECR, and Cloudwatch Logs
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.prefix}-tunnel"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  capacity_provider_strategy {
    capacity_provider = var.fargate_type
    weight            = 100
    base              = 1
  }
  network_configuration {
    subnets = var.private_subnets
    security_groups = [
      aws_security_group.tunnel.id
    ]
  }
}