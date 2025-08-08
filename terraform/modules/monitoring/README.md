# Monitoring Module

This module provides comprehensive CloudWatch monitoring and alerting for the ECS deployment, including SNS notifications for various alarm conditions.

## Features

- **SNS Topic & Subscriptions**: Email and Slack notifications
- **ECS Service Monitoring**: CPU, memory, and task count alarms
- **ALB Health Monitoring**: Target health and response time alarms
- **Error Rate Monitoring**: 5XX error tracking
- **CloudWatch Dashboard**: Visual monitoring dashboard
- **Customizable Thresholds**: Configurable alarm thresholds

## Alarms Created

### ECS Service Alarms
1. **CPU Utilization High** - Triggers when CPU usage exceeds threshold
2. **Memory Utilization High** - Triggers when memory usage exceeds threshold
3. **Running Tasks Low** - Triggers when task count drops below minimum

### ALB Alarms
4. **Unhealthy Targets** - Triggers when targets become unhealthy
5. **Response Time High** - Triggers when response time exceeds threshold
6. **5XX Errors** - Triggers when 5XX error count exceeds threshold

## Resources Created

1. **aws_sns_topic.alerts** - SNS topic for all alerts
2. **aws_sns_topic_policy.alerts** - Policy allowing CloudWatch to publish
3. **aws_sns_topic_subscription.email_alerts** - Email subscriptions
4. **aws_sns_topic_subscription.slack_webhook** - Slack webhook subscription
5. **aws_cloudwatch_metric_alarm.*** - Various CloudWatch alarms
6. **aws_cloudwatch_dashboard.main** - Monitoring dashboard
7. **aws_cloudwatch_log_group.monitoring** - Custom metrics log group

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  project_name = "my-app"
  environment  = "prod"
  tags         = {
    Project     = "my-app"
    Environment = "prod"
  }

  # SNS Configuration
  alert_email_addresses = [
    "admin@company.com",
    "devops@company.com"
  ]
  slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

  # ECS Service Information
  cluster_name          = module.ecs.cluster_name
  backend_service_name  = module.ecs.backend_service_name
  frontend_service_name = module.ecs.frontend_service_name

  # ALB Information
  alb_arn_suffix                   = module.ecs.alb_arn_suffix
  backend_target_group_arn_suffix  = module.ecs.backend_target_group_arn_suffix
  frontend_target_group_arn_suffix = module.ecs.frontend_target_group_arn_suffix

  # Custom Thresholds
  cpu_threshold_high     = 85
  memory_threshold_high  = 85
  response_time_threshold = 1.5
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | `"dev"` | no |
| tags | Tags to apply to all monitoring resources | `map(string)` | `{}` | no |
| alert_email_addresses | List of email addresses to receive alerts | `list(string)` | `[]` | no |
| slack_webhook_url | Slack webhook URL for notifications | `string` | `""` | no |
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| backend_service_name | Name of the backend ECS service | `string` | n/a | yes |
| frontend_service_name | Name of the frontend ECS service | `string` | n/a | yes |
| alb_arn_suffix | ARN suffix of the Application Load Balancer | `string` | n/a | yes |
| backend_target_group_arn_suffix | ARN suffix of the backend target group | `string` | n/a | yes |
| frontend_target_group_arn_suffix | ARN suffix of the frontend target group | `string` | n/a | yes |
| cpu_threshold_high | CPU utilization threshold for high CPU alarm (%) | `number` | `80` | no |
| memory_threshold_high | Memory utilization threshold for high memory alarm (%) | `number` | `80` | no |
| min_running_tasks | Minimum number of running tasks before triggering alarm | `number` | `1` | no |
| response_time_threshold | Response time threshold in seconds | `number` | `2.0` | no |
| error_5xx_threshold | 5XX error count threshold | `number` | `10` | no |
| enable_dashboard | Enable CloudWatch dashboard | `bool` | `true` | no |
| enable_custom_metrics | Enable custom metrics and log groups | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| sns_topic_arn | ARN of the SNS topic for alerts |
| sns_topic_name | Name of the SNS topic for alerts |
| dashboard_url | URL of the CloudWatch dashboard |
| alarm_names | List of CloudWatch alarm names |
| monitoring_log_group_name | Name of the monitoring log group |

## Notification Setup

### Email Notifications
1. Add email addresses to the `alert_email_addresses` variable
2. After deployment, check your email for subscription confirmation
3. Click the confirmation link to start receiving alerts

### Slack Notifications
1. Create a Slack webhook in your workspace:
   - Go to https://api.slack.com/messaging/webhooks
   - Create a new webhook app
   - Copy the webhook URL
2. Set the `slack_webhook_url` variable with your webhook URL
3. Alerts will be posted to the configured Slack channel

## Dashboard Access

The CloudWatch dashboard provides a centralized view of:
- ECS service CPU and memory utilization
- ALB response times and request counts
- Error rates and healthy target counts

Access the dashboard using the URL from the `dashboard_url` output.

## Alarm States

Alarms can be in three states:
- **OK** - Metric is within normal range
- **ALARM** - Metric has breached the threshold
- **INSUFFICIENT_DATA** - Not enough data to determine state

## Customization

### Adding Custom Alarms
To add additional alarms, extend the module by adding new `aws_cloudwatch_metric_alarm` resources.

### Modifying Thresholds
Adjust the threshold variables in your terraform.tfvars:

```hcl
cpu_threshold_high     = 90
memory_threshold_high  = 85
response_time_threshold = 1.0
error_5xx_threshold    = 5
```

### Integration with External Monitoring
The SNS topic ARN can be used to integrate with external monitoring systems like PagerDuty, Datadog, or custom Lambda functions.

## Best Practices

1. **Set Appropriate Thresholds**: Start with conservative thresholds and adjust based on your application's behavior
2. **Monitor Alarm Fatigue**: Too many false alarms can lead to ignored notifications
3. **Test Notifications**: Verify email and Slack notifications are working
4. **Regular Review**: Periodically review and adjust alarm thresholds
5. **Document Runbooks**: Create procedures for responding to each type of alarm

## Troubleshooting

### Email Subscriptions Not Working
- Check if confirmation emails are in spam folder
- Verify email addresses are correct in the configuration
- Check SNS topic subscription status in AWS console

### Slack Notifications Not Working
- Verify webhook URL is correct and active
- Check Slack app permissions
- Test webhook URL manually with curl

### Missing Metrics
- Ensure ECS services are running and generating metrics
- Check that ALB is receiving traffic
- Verify resource names match exactly
