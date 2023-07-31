resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE_SPOT"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.prefix}-taskdef"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.taskrole.arn
  execution_role_arn       = aws_iam_role.executionrole.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "cloudflared"
      essential = true
      // todo, versioning
      image   = "cloudflare/cloudflared:latest",
      command = ["tunnel", "run", cloudflare_tunnel.tunnel.id]
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
  description = "This is the security group for the tunnel instances"
  vpc_id      = var.vpc_id
  // does not require any ingress ports, just egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.prefix}-tunnel"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 3
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
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