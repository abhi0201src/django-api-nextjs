aws_region = "us-west-2"
project_name = "django-nextjs-app"
environment = "dev"

backend_environment_variables = {
  DEBUG = "False"
  DJANGO_ALLOWED_HOSTS = "*"
  CORS_ALLOWED_ORIGINS = "http://localhost:3000"
  DJANGO_SECRET_KEY = "django-insecure-k*9zr39ed7aq2u-temp-key-for-dev"  # Change this in production
}

default_tags = {
  Project     = "django-nextjs-app"
  Environment = "dev"
  ManagedBy   = "terraform"
}
