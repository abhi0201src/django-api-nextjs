# Required variables
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

variable "alert_email_endpoint" {
  description = "Email id to receive alerts"
  type        = string
  default     = "abhishek.sa.2001@gmail.com"
}

# Networking variables

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
