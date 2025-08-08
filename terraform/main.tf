# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.default_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name    = var.project_name
  environment     = var.environment
  tags            = var.default_tags
  
  # Optional: Enable auto scaling
  enable_auto_scaling = false
  
  # ECR repository ARNs for enhanced security
  ecr_repository_arns = [
    module.ecr.backend_repository_arn,
    module.ecr.frontend_repository_arn
  ]
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  tags                 = var.default_tags
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  project_name                  = var.project_name
  environment                   = var.environment
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnet_ids
  public_subnet_ids             = module.vpc.public_subnet_ids
  backend_image                 = "${module.ecr.backend_repository_url}:latest"
  frontend_image                = "${module.ecr.frontend_repository_url}:latest"
  certificate_arn               = var.certificate_arn
  domain_name                   = var.domain_name
  backend_environment_variables = var.backend_environment_variables
  tags                          = var.default_tags
  
  # IAM roles from IAM module
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn

  # Optional: Customize resource allocation
  backend_cpu     = 256
  backend_memory  = 512
  frontend_cpu    = 256
  frontend_memory = 512

  desired_count_backend  = 2
  desired_count_frontend = 2
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.default_tags

  # SNS Configuration
  alert_email_addresses = var.alert_email_addresses
  slack_webhook_url     = var.slack_webhook_url

  # ECS Service Information
  cluster_name           = module.ecs.cluster_name
  backend_service_name   = module.ecs.backend_service_name
  frontend_service_name  = module.ecs.frontend_service_name

  # ALB Information
  alb_arn_suffix                    = module.ecs.alb_arn_suffix
  backend_target_group_arn_suffix   = module.ecs.backend_target_group_arn_suffix
  frontend_target_group_arn_suffix  = module.ecs.frontend_target_group_arn_suffix

  # Alarm Thresholds (customize as needed)
  cpu_threshold_high     = var.cpu_threshold_high
  memory_threshold_high  = var.memory_threshold_high
  min_running_tasks      = var.min_running_tasks
  response_time_threshold = var.response_time_threshold
  error_5xx_threshold    = var.error_5xx_threshold

  # Optional Features
  enable_dashboard      = var.enable_dashboard
  enable_custom_metrics = var.enable_custom_metrics
}
