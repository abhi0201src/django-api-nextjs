provider "aws" {
  region = var.aws_region
}

# Default VPC and Subnets
data "aws_vpc" "default" {
  default = true
}

# Public subnets (tagged Tier=Public)
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

# Private subnets (tagged Tier=Private)
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}



# ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "django-nextjs-cluster"
}



# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "nextjs-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "nextjs-frontend",
    image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.frontend_image_repo}:latest",
    portMappings = [{
      containerPort = 3000,
      hostPort      = 3000
    }]
  }])
}

# Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "django-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "django-backend",
    image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.backend_image_repo}:latest",
    portMappings = [{
      containerPort = 8000,
      hostPort      = 8000
    }],
  }])
}
