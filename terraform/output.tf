output "frontend_url" {
  description = "URL to access the frontend application"
  value       = "http://${aws_lb.frontend_alb.dns_name}"
}

output "backend_url" {
  description = "Internal URL for backend API"
  value       = "http://${aws_lb.backend_alb.dns_name}"
  sensitive   = true
}
