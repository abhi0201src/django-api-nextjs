output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.name
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = var.enable_dashboard ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : null
}

output "alarm_names" {
  description = "List of CloudWatch alarm names"
  value = [
    aws_cloudwatch_metric_alarm.backend_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.backend_memory_high.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_memory_high.alarm_name,
    aws_cloudwatch_metric_alarm.backend_running_tasks_low.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_running_tasks_low.alarm_name,
    aws_cloudwatch_metric_alarm.backend_unhealthy_targets.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_unhealthy_targets.alarm_name,
    aws_cloudwatch_metric_alarm.backend_response_time_high.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_response_time_high.alarm_name,
    aws_cloudwatch_metric_alarm.alb_5xx_errors.alarm_name
  ]
}

output "monitoring_log_group_name" {
  description = "Name of the monitoring log group"
  value       = var.enable_custom_metrics ? aws_cloudwatch_log_group.monitoring[0].name : null
}
