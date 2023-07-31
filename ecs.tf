// todo change prefix to prevent conflicts
module "ecs_dockerhub_clone" {
  source                  = "elasticscale/ecs-dockerhub-clone/aws"
  version                 = "3.0.2"
  docker_hub_username     = var.docker_hub_username
  docker_hub_access_token = var.docker_hub_access_token
  containers = {
    // todo, version management
    "cloudflare/cloudflared" = ["latest"],
    "amazon/aws-cli"         = ["2.13.5"]
  }
  build_commands = {
    "cloudflare/cloudflared:latest" = [
      "VOLUME [\"/etc/cloudflared\"]"
    ],
    "amazon/aws-cli:2.13.5" = [
      "RUN mkdir /etc/cloudflared",
      "RUN chmod 777 /etc/cloudflared",
      "VOLUME [\"/etc/cloudflared\"]"
    ]
  }
}

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
      image   = "${module.ecs_dockerhub_clone.image_base_url}cloudflare/cloudflared:latest",
      command = ["tunnel", "run", "--token", cloudflare_tunnel.tunnel.tunnel_token]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.logs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "cloudflared"
        }
      }
      dependsOn = [
        {
          containerName = "awscli"
          condition     = "SUCCESS"
        }
      ]
    },
    {
      name      = "awscli"
      essential = false
      // todo, versioning
      image   = "${module.ecs_dockerhub_clone.image_base_url}amazon/aws-cli:2.13.5"
      command = ["s3", "sync", "s3://${aws_s3_bucket.main.id}/", "/etc/cloudflared/"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.logs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "awscli"
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