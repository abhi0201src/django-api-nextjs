variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all monitoring resources"
  type        = map(string)
  default     = {}
}

# SNS Configuration
variable "alert_email_addresses" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = []
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

# ECS Service Information
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "backend_service_name" {
  description = "Name of the backend ECS service"
  type        = string
}

variable "frontend_service_name" {
  description = "Name of the frontend ECS service"
  type        = string
}

# ALB Information
variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  type        = string
}

variable "backend_target_group_arn_suffix" {
  description = "ARN suffix of the backend target group"
  type        = string
}

variable "frontend_target_group_arn_suffix" {
  description = "ARN suffix of the frontend target group"
  type        = string
}

# Alarm Thresholds
variable "cpu_threshold_high" {
  description = "CPU utilization threshold for high CPU alarm (percentage)"
  type        = number
  default     = 80
}

variable "memory_threshold_high" {
  description = "Memory utilization threshold for high memory alarm (percentage)"
  type        = number
  default     = 80
}

variable "min_running_tasks" {
  description = "Minimum number of running tasks before triggering alarm"
  type        = number
  default     = 1
}

variable "response_time_threshold" {
  description = "Response time threshold in seconds"
  type        = number
  default     = 2.0
}

variable "error_5xx_threshold" {
  description = "5XX error count threshold"
  type        = number
  default     = 10
}

# Optional Features
variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "enable_custom_metrics" {
  description = "Enable custom metrics and log groups"
  type        = bool
  default     = false
}
