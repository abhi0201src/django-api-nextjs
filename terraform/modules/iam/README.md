# IAM Module

This module manages all IAM-related resources for the ECS deployment, including roles, policies, and permissions required for ECS services to run properly.

## Features

- **ECS Task Execution Role**: Role for ECS to pull container images and write logs
- **ECS Task Role**: Role for containers to access other AWS services
- **CloudWatch Logs Permissions**: Custom policy for enhanced logging capabilities
- **ECR Access**: Permissions to pull container images from ECR
- **Auto Scaling Support**: Optional IAM role for ECS service auto scaling
- **Custom Policies**: Support for additional application-specific permissions

## Resources Created

1. **aws_iam_role.ecs_task_execution_role** - ECS task execution role
2. **aws_iam_role.ecs_task_role** - ECS task role for application containers
3. **aws_iam_policy.ecs_cloudwatch_logs_policy** - CloudWatch Logs permissions
4. **aws_iam_policy.ecr_access_policy** - ECR access permissions
5. **aws_iam_role.ecs_auto_scaling_role** - Auto scaling role (optional)
6. **aws_iam_policy.ecs_task_policy** - Custom task policy (optional)

## Usage

```hcl
module "iam" {
  source = "./modules/iam"

  project_name = "my-app"
  environment  = "dev"
  tags         = {
    Project     = "my-app"
    Environment = "dev"
  }
  
  # Optional: Enable auto scaling
  enable_auto_scaling = true
  
  # Optional: Add custom permissions
  additional_task_policies = [
    {
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | `"dev"` | no |
| tags | Tags to apply to all IAM resources | `map(string)` | `{}` | no |
| additional_task_policies | Additional IAM policy statements for ECS tasks | `list(object)` | `[]` | no |
| enable_auto_scaling | Enable auto scaling IAM role for ECS services | `bool` | `false` | no |
| ecr_repository_arns | List of ECR repository ARNs that ECS tasks need access to | `list(string)` | `["*"]` | no |
| cloudwatch_log_group_arns | List of CloudWatch Log Group ARNs for ECS tasks | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs_task_execution_role_arn | ARN of the ECS task execution role |
| ecs_task_execution_role_name | Name of the ECS task execution role |
| ecs_task_role_arn | ARN of the ECS task role |
| ecs_task_role_name | Name of the ECS task role |
| ecs_auto_scaling_role_arn | ARN of the ECS auto scaling role |
| ecs_auto_scaling_role_name | Name of the ECS auto scaling role |
| cloudwatch_logs_policy_arn | ARN of the CloudWatch Logs policy |
| ecr_access_policy_arn | ARN of the ECR access policy |
| ecs_task_custom_policy_arn | ARN of the custom ECS task policy |
| current_account_id | Current AWS account ID |
| current_region | Current AWS region |

## Security Best Practices

- **Least Privilege**: All policies follow the principle of least privilege
- **Resource-Specific Permissions**: Permissions are scoped to specific resources when possible
- **Separate Roles**: Task execution and task roles are separated for better security
- **Custom Policies**: Support for application-specific permissions without overly broad access

## Integration with Other Modules

This module is designed to work with:
- **ECS Module**: Provides IAM roles for ECS services and tasks
- **ECR Module**: Gets repository ARNs for enhanced security policies
- **VPC Module**: No direct integration needed

## Examples

### Basic Usage
```hcl
module "iam" {
  source = "./modules/iam"
  
  project_name = "django-nextjs-app"
  environment  = "dev"
}
```

### With Custom Permissions
```hcl
module "iam" {
  source = "./modules/iam"
  
  project_name = "django-nextjs-app"
  environment  = "prod"
  
  additional_task_policies = [
    {
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        "arn:aws:secretsmanager:us-west-2:123456789012:secret:prod/database-*"
      ]
    }
  ]
}
```

### With Auto Scaling
```hcl
module "iam" {
  source = "./modules/iam"
  
  project_name        = "django-nextjs-app"
  environment         = "prod"
  enable_auto_scaling = true
}
```
