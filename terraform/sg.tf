# Security Groups
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Allow HTTP/HTTPS inbound traffic to ALB"
  vpc_id      = aws_vpc.main.id  # Changed to new VPC

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LoadBalancer-SG"
  }
}

resource "aws_security_group" "frontend_ecs_sg" {
  name        = "frontend-ecs-sg"
  description = "Allow traffic from frontend ALB to frontend ECS"
  vpc_id      = aws_vpc.main.id  # Changed to new VPC

  ingress {
    description     = "Allow from frontend ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Frontend-ECS-SG"
  }
}

resource "aws_security_group" "backend_ecs_sg" {
  name        = "backend-ecs-sg"
  description = "Allow traffic from frontend ECS to backend ECS"
  vpc_id      = aws_vpc.main.id

  # allow from frontend ECS
  ingress {
    description     = "Allow from frontend ECS"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_ecs_sg.id]
  }

  # Allow ALB health checks if needed
  ingress {
    description     = "Allow ALB health checks"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Backend-ECS-SG"
  }
}

