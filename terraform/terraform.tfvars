aws_region = "us-west-2"
project_name = "django-nextjs-app"
environment = "dev"

backend_environment_variables = {
  DEBUG = "False"
}

default_tags = {
  Project     = "django-nextjs-app"
  Environment = "dev"
  ManagedBy   = "terraform"
}

# Monitoring Configuration
alert_email_addresses = [
  # Add your email addresses here for alerts
  # "admin@company.com",
  # "devops@company.com"
]

# Optional: Slack webhook URL for notifications
# slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

# CloudWatch Alarm Thresholds
cpu_threshold_high     = 80
memory_threshold_high  = 80
min_running_tasks      = 1
response_time_threshold = 2.0
error_5xx_threshold    = 10

# Dashboard and Custom Metrics
enable_dashboard      = true
enable_custom_metrics = false
