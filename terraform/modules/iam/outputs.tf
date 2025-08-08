output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.name
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.ecs_task_role.name
}

output "ecs_auto_scaling_role_arn" {
  description = "ARN of the ECS auto scaling role"
  value       = var.enable_auto_scaling ? aws_iam_role.ecs_auto_scaling_role[0].arn : null
}

output "ecs_auto_scaling_role_name" {
  description = "Name of the ECS auto scaling role"
  value       = var.enable_auto_scaling ? aws_iam_role.ecs_auto_scaling_role[0].name : null
}

output "cloudwatch_logs_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  value       = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
}

output "ecr_access_policy_arn" {
  description = "ARN of the ECR access policy"
  value       = aws_iam_policy.ecr_access_policy.arn
}

output "ecs_task_custom_policy_arn" {
  description = "ARN of the custom ECS task policy"
  value       = length(var.additional_task_policies) > 0 ? aws_iam_policy.ecs_task_policy[0].arn : null
}

output "current_account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "current_region" {
  description = "Current AWS region"
  value       = data.aws_region.current.name
}
