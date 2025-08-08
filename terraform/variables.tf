variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "django-nextjs-app"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "certificate_arn" {
  description = "SSL certificate ARN for HTTPS (optional)"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the application (optional)"
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

variable "backend_image" {
  description = "Docker image for backend"
  type        = string
  default     = ""
}

variable "frontend_image" {
  description = "Docker image for frontend"
  type        = string
  default     = ""
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "django-nextjs-app"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Monitoring Configuration
variable "alert_email_addresses" {
  description = "List of email addresses to receive CloudWatch alerts"
  type        = list(string)
  default     = []
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

# Monitoring Thresholds
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
