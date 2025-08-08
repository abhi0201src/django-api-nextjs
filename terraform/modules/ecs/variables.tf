variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "backend_image" {
  description = "Docker image for Django backend"
  type        = string
}

variable "frontend_image" {
  description = "Docker image for Next.js frontend"
  type        = string
}

variable "backend_port" {
  description = "Port for Django backend"
  type        = number
  default     = 8000
}

variable "frontend_port" {
  description = "Port for Next.js frontend"
  type        = number
  default     = 3000
}

variable "backend_cpu" {
  description = "CPU units for backend service"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory for backend service"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "CPU units for frontend service"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Memory for frontend service"
  type        = number
  default     = 512
}

variable "desired_count_backend" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 2
}

variable "desired_count_frontend" {
  description = "Desired number of frontend tasks"
  type        = number
  default     = 2
}

variable "certificate_arn" {
  description = "SSL certificate ARN for HTTPS"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "backend_environment_variables" {
  description = "Environment variables for backend"
  type        = map(string)
  default = {
    DEBUG = "False"
  }
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
