aws_region = "us-west-2"
project_name = "django-nextjs-app"
environment = "dev"

backend_environment_variables = {
  DEBUG = "False"
  DJANGO_ALLOWED_HOSTS = "*"
  CORS_ALLOWED_ORIGINS = "https://${var.domain_name},http://${var.domain_name}"
  DJANGO_SECRET_KEY = "your-secure-secret-key-here"  # Change this in production
}

# Frontend environment variables will be injected at build time
frontend_environment_variables = {
  NEXT_PUBLIC_API_URL = "https://api.${var.domain_name}"  # Will be set to the backend service URL
}

default_tags = {
  Project     = "django-nextjs-app"
  Environment = "dev"
  ManagedBy   = "terraform"
}

# Load balancer and DNS settings
enable_https = true
create_dns_records = true
