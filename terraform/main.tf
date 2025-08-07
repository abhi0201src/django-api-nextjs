provider "aws" {
  region = var.aws_region
}

# Networking components
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "django-nextjs-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "django-nextjs-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "django-nextjs-nat"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
    Tier = "Public"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-subnet-${count.index}"
    Tier = "Private"
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
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

resource "aws_ecs_task_definition" "backend" {
  family                   = "django-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "django-migrate",
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.backend_image_repo}:latest",
      essential = false,
      command   = ["python", "manage.py", "migrate"],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/backend",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      },
      environment = [
        {
          name  = "DJANGO_ALLOWED_HOSTS",
          value = join(",", [
            aws_lb.backend_alb.dns_name,
            "localhost",
            "127.0.0.1",
            var.vpc_cidr
          ])
        }
      ]
    },
    {
      name      = "django-backend",
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.backend_image_repo}:latest",
      essential = true,
      portMappings = [{
        containerPort = 8000,
        hostPort      = 8000,
        protocol      = "tcp"
      }],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/backend",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health/ || exit 1"],
        interval    = 30,
        timeout     = 5,
        retries     = 3,
        startPeriod = 60
      },
      environment = [
        {
          name  = "DJANGO_ALLOWED_HOSTS",
          value = join(",", [
            aws_lb.backend_alb.dns_name,
            "localhost",
            "127.0.0.1",
            var.vpc_cidr
          ])
        }
      ],
      dependsOn = [
        {
          containerName = "django-migrate",
          condition     = "SUCCESS"
        }
      ]
    }
  ])
}
