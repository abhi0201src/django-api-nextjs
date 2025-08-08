# CloudWatch Monitoring and Alerting Setup

This document describes the comprehensive monitoring solution implemented for the Django + Next.js ECS application.

## Overview

The monitoring module provides:
- ✅ **SNS Topic** for centralized alerting
- ✅ **Email Notifications** for immediate alerts
- ✅ **Slack Integration** for team notifications
- ✅ **CloudWatch Alarms** for key metrics
- ✅ **CloudWatch Dashboard** for visual monitoring
- ✅ **Customizable Thresholds** for different environments

## Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CloudWatch Monitoring                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │
│  │ ECS Service │    │     ALB     │    │   Targets   │             │
│  │   Metrics   │    │   Metrics   │    │   Health    │             │
│  └─────────────┘    └─────────────┘    └─────────────┘             │
│         │                   │                   │                   │
│         └───────────────────┼───────────────────┘                   │
│                             │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │               CloudWatch Alarms                                ││
│  │  • CPU High           • Memory High        • Tasks Low         ││
│  │  • Response Time      • 5XX Errors        • Unhealthy Targets ││
│  └─────────────────────────────────────────────────────────────────┘│
│                             │                                       │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                     SNS Topic                                   ││
│  └─────────────────────────────────────────────────────────────────┘│
│                             │                                       │
│         ┌───────────────────┼───────────────────┐                   │
│         │                   │                   │                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │
│  │    Email    │    │    Slack    │    │   Custom    │             │
│  │    Alerts   │    │   Webhook   │    │    Lambda   │             │
│  └─────────────┘    └─────────────┘    └─────────────┘             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Alarms Configuration

### 1. ECS Service Alarms

| Alarm Name | Metric | Threshold | Description |
|------------|--------|-----------|-------------|
| `{project}-{env}-backend-cpu-high` | CPUUtilization | 80% | Backend CPU usage |
| `{project}-{env}-frontend-cpu-high` | CPUUtilization | 80% | Frontend CPU usage |
| `{project}-{env}-backend-memory-high` | MemoryUtilization | 80% | Backend memory usage |
| `{project}-{env}-frontend-memory-high` | MemoryUtilization | 80% | Frontend memory usage |
| `{project}-{env}-backend-tasks-low` | RunningTaskCount | < 1 | Backend service availability |
| `{project}-{env}-frontend-tasks-low` | RunningTaskCount | < 1 | Frontend service availability |

### 2. ALB Health Alarms

| Alarm Name | Metric | Threshold | Description |
|------------|--------|-----------|-------------|
| `{project}-{env}-backend-unhealthy-targets` | UnHealthyHostCount | > 0 | Backend target health |
| `{project}-{env}-frontend-unhealthy-targets` | UnHealthyHostCount | > 0 | Frontend target health |
| `{project}-{env}-backend-response-time-high` | TargetResponseTime | > 2s | Backend response performance |
| `{project}-{env}-frontend-response-time-high` | TargetResponseTime | > 2s | Frontend response performance |

### 3. Error Rate Alarms

| Alarm Name | Metric | Threshold | Description |
|------------|--------|-----------|-------------|
| `{project}-{env}-alb-5xx-errors` | HTTPCode_ELB_5XX_Count | > 10 | Application errors |

## Configuration Steps

### 1. Basic Setup (No Email/Slack)
```hcl
# terraform/terraform.tfvars
alert_email_addresses = []
slack_webhook_url = ""
enable_dashboard = true
```

### 2. Email Notifications Setup
```hcl
# terraform/terraform.tfvars
alert_email_addresses = [
  "admin@company.com",
  "devops@company.com"
]
```

**Post-Deployment Steps:**
1. Check your email for SNS subscription confirmation
2. Click "Confirm subscription" link in each email
3. Verify alerts are working by triggering a test alarm

### 3. Slack Integration Setup

**Step 1: Create Slack Webhook**
1. Go to https://api.slack.com/messaging/webhooks
2. Click "Create your Slack app"
3. Choose "From scratch" → Enter app name → Select workspace
4. Go to "Incoming Webhooks" → Toggle "On"
5. Click "Add New Webhook to Workspace"
6. Select channel → Click "Allow"
7. Copy the webhook URL

**Step 2: Configure Terraform**
```hcl
# terraform/terraform.tfvars
slack_webhook_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
```

### 4. Custom Thresholds
```hcl
# terraform/terraform.tfvars
cpu_threshold_high     = 90      # Increase for less sensitive CPU alerts
memory_threshold_high  = 85      # Increase for less sensitive memory alerts
response_time_threshold = 1.5    # Decrease for faster response time alerts
error_5xx_threshold    = 5       # Decrease for more sensitive error alerts
min_running_tasks      = 2       # Increase if running multiple tasks per service
```

## Dashboard Access

After deployment, access the CloudWatch dashboard:

1. **Via Terraform Output:**
   ```bash
   terraform output dashboard_url
   ```

2. **Manual Access:**
   - Go to AWS CloudWatch Console
   - Navigate to "Dashboards"
   - Look for `{project-name}-{environment}-dashboard`

**Dashboard Widgets:**
- ECS Service CPU and Memory Utilization
- ALB Response Times and Request Counts
- Error Rates and Target Health Status

## Testing Alerts

### 1. Test Email Notifications
```bash
# Trigger a test alarm (simulate high CPU)
aws cloudwatch put-metric-data \
  --namespace "AWS/ECS" \
  --metric-data MetricName=CPUUtilization,Value=90,Unit=Percent,Dimensions=ServiceName=your-backend-service,ClusterName=your-cluster
```

### 2. Test Application Health
```bash
# Test backend health endpoint
curl http://your-alb-dns-name/health/

# Test frontend
curl http://your-alb-dns-name/
```

### 3. Simulate Load (Optional)
```bash
# Install and use Apache Bench for load testing
sudo apt-get install apache2-utils
ab -n 1000 -c 10 http://your-alb-dns-name/
```

## Troubleshooting

### Common Issues

**1. Email Subscriptions Not Confirmed**
```bash
# Check SNS subscription status
aws sns list-subscriptions-by-topic --topic-arn arn:aws:sns:region:account:topic-name
```
- Look for "PendingConfirmation" status
- Check spam folders for confirmation emails

**2. Slack Notifications Not Working**
```bash
# Test webhook manually
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test alert from CloudWatch"}' \
  https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
```

**3. Missing Metrics**
```bash
# Check if ECS services are running
aws ecs describe-services --cluster your-cluster --services your-service

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn your-target-group-arn
```

**4. False Alarms**
- Adjust thresholds in `terraform.tfvars`
- Increase evaluation periods for less sensitive alarms
- Review application baseline performance

### Monitoring Best Practices

1. **Start Conservative**: Begin with higher thresholds and adjust down
2. **Monitor Trends**: Use dashboard to understand normal patterns
3. **Document Responses**: Create runbooks for each alarm type
4. **Regular Reviews**: Monthly review of alarm effectiveness
5. **Test Regularly**: Verify notification channels work

## Cost Considerations

**CloudWatch Costs:**
- Alarms: ~$0.10 per alarm per month (11 alarms = ~$1.10/month)
- Dashboard: ~$3.00 per dashboard per month
- SNS: ~$0.50 per 1M requests
- Log storage: Based on retention and volume

**Typical Monthly Cost: ~$5-10 for basic monitoring**

## Next Steps

1. **Deploy with Basic Setup**: Start with email notifications only
2. **Add Slack Integration**: Configure team notifications
3. **Customize Thresholds**: Adjust based on application behavior
4. **Create Runbooks**: Document response procedures
5. **Set Up Escalation**: Configure PagerDuty or similar for critical alerts
6. **Monitor Costs**: Review CloudWatch usage monthly

## Support

For issues with the monitoring setup:
1. Check Terraform outputs for resource information
2. Review CloudWatch console for alarm states
3. Verify SNS topic and subscription configuration
4. Test notification endpoints manually
5. Review application logs for performance patterns
