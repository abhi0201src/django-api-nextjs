# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    Type = "ECS-Task-Execution"
  })
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-task-role"
    Type = "ECS-Task"
  })
}

# Attach the AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for CloudWatch Logs (if additional permissions needed)
resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "${var.project_name}-${var.environment}-ecs-cloudwatch-logs"
  description = "Policy for ECS tasks to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/ecs/${var.project_name}-${var.environment}-*",
          "arn:aws:logs:*:*:log-group:/ecs/${var.project_name}-${var.environment}-*:*"
        ]
      }
    ]
  })

  tags = var.tags
}

# Attach CloudWatch Logs policy to task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_cloudwatch_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
}

# Custom policy for ECS tasks (application-specific permissions)
resource "aws_iam_policy" "ecs_task_policy" {
  count       = length(var.additional_task_policies) > 0 ? 1 : 0
  name        = "${var.project_name}-${var.environment}-ecs-task-policy"
  description = "Custom policy for ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.additional_task_policies
  })

  tags = var.tags
}

# Attach custom task policy to task role
resource "aws_iam_role_policy_attachment" "ecs_task_custom_policy" {
  count      = length(var.additional_task_policies) > 0 ? 1 : 0
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy[0].arn
}

# ECR access policy for task execution role (to pull images)
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "${var.project_name}-${var.environment}-ecr-access"
  description = "Policy for ECS task execution to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Attach ECR access policy to task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_ecr_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# Optional: Auto Scaling Role for ECS services
resource "aws_iam_role" "ecs_auto_scaling_role" {
  count = var.enable_auto_scaling ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-auto-scaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-auto-scaling-role"
    Type = "ECS-Auto-Scaling"
  })
}

# Attach auto scaling policy
resource "aws_iam_role_policy_attachment" "ecs_auto_scaling_policy" {
  count      = var.enable_auto_scaling ? 1 : 0
  role       = aws_iam_role.ecs_auto_scaling_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSServiceRolePolicy"
}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# Data source for current AWS region
data "aws_region" "current" {}
