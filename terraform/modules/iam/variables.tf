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
  description = "Tags to apply to all IAM resources"
  type        = map(string)
  default     = {}
}

variable "additional_task_policies" {
  description = "Additional IAM policy statements for ECS tasks"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
    Condition = optional(map(any))
  }))
  default = []
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling IAM role for ECS services"
  type        = bool
  default     = false
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs that ECS tasks need access to"
  type        = list(string)
  default     = ["*"]
}

variable "cloudwatch_log_group_arns" {
  description = "List of CloudWatch Log Group ARNs for ECS tasks"
  type        = list(string)
  default     = []
}
