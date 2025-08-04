variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  sensitive   = true
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "backend_image_repo" {
  description = "ECR repo for backend"
  type        = string
  default     = "django-backend"
}

variable "frontend_image_repo" {
  description = "ECR repo for frontend"
  type        = string
  default     = "nextjs-frontend"
}
