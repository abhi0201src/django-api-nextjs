# ECR Outputs
output "backend_ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.ecr.backend_repository_url
}

output "frontend_ecr_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = module.ecr.frontend_repository_url
}

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# ECS Outputs
output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.ecs.alb_zone_id
}

output "backend_service_name" {
  description = "Name of the backend ECS service"
  value       = module.ecs.backend_service_name
}

output "frontend_service_name" {
  description = "Name of the frontend ECS service"
  value       = module.ecs.frontend_service_name
}

# IAM Outputs
output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.iam.ecs_task_role_arn
}

# Application URLs
output "application_url" {
  description = "URL to access the application"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : (var.certificate_arn != "" ? "https://${module.ecs.alb_dns_name}" : "http://${module.ecs.alb_dns_name}")
}

output "api_url" {
  description = "URL to access the API"
  value       = var.domain_name != "" ? "https://${var.domain_name}/api/" : (var.certificate_arn != "" ? "https://${module.ecs.alb_dns_name}/api/" : "http://${module.ecs.alb_dns_name}/api/")
}

output "admin_url" {
  description = "URL to access Django Admin"
  value       = var.domain_name != "" ? "https://${var.domain_name}/admin/" : (var.certificate_arn != "" ? "https://${module.ecs.alb_dns_name}/admin/" : "http://${module.ecs.alb_dns_name}/admin/")
}

output "health_url" {
  description = "URL to access health check"
  value       = var.domain_name != "" ? "https://${var.domain_name}/health/" : (var.certificate_arn != "" ? "https://${module.ecs.alb_dns_name}/health/" : "http://${module.ecs.alb_dns_name}/health/")
}

# Monitoring Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

output "alarm_names" {
  description = "List of CloudWatch alarm names"
  value       = module.monitoring.alarm_names
}
