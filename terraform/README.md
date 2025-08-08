# Django + Next.js Application - AWS ECS Deployment

This project contains a complete Terraform setup to deploy a Django API backend and Next.js frontend to AWS ECS (Elastic Container Service) with an Application Load Balancer.

## Architecture

The deployment includes:
- **VPC** with public and private subnets across multiple AZs
- **ECR repositories** for storing Docker images
- **ECS cluster** running on AWS Fargate
- **Application Load Balancer** for routing traffic
- **Security groups** for network security
- **CloudWatch logs** for monitoring

```
Internet → ALB → ECS Tasks (Frontend + Backend)
                    ↓
                Private Subnets
```

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** (>= 1.0)
3. **Docker** for building images
4. **AWS Account** with sufficient permissions

### Required AWS Permissions

Your AWS user/role needs permissions for:
- ECS (all actions)
- ECR (all actions)
- VPC (all actions)
- EC2 (security groups, load balancers)
- IAM (roles and policies)
- CloudWatch (logs)

## Quick Start

### 1. Clone and Navigate
```bash
cd django-api-nextjs
```

### 2. Configure AWS
```bash
aws configure
# Or set environment variables:
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-west-2
```

### 3. Deploy Everything
```bash
./deploy.sh deploy
```

This script will:
1. Create ECR repositories
2. Build and push Docker images
3. Deploy infrastructure with Terraform
4. Start ECS services

### 4. Access Your Application
After deployment, you'll get outputs with:
- ALB DNS name for accessing your application
- ECR repository URLs
- ECS cluster information

## Manual Deployment

If you prefer manual steps:

### 1. Create ECR Repositories
```bash
aws ecr create-repository --repository-name django-nextjs-app-dev-backend --region us-west-2
aws ecr create-repository --repository-name django-nextjs-app-dev-frontend --region us-west-2
```

### 2. Build and Push Docker Images
```bash
# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com

# Build and push backend
docker build -t django-nextjs-app-backend .
docker tag django-nextjs-app-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/django-nextjs-app-dev-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/django-nextjs-app-dev-backend:latest

# Build and push frontend
docker build -t django-nextjs-app-frontend -f menu-frontend/Dockerfile.frontend menu-frontend/
docker tag django-nextjs-app-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/django-nextjs-app-dev-frontend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/django-nextjs-app-dev-frontend:latest
```

### 3. Deploy with Terraform
```bash
cd terraform

# Copy and edit the variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your ECR image URLs

# Deploy
terraform init
terraform plan
terraform apply
```

## Configuration

### Environment Variables

Edit `terraform/terraform.tfvars` to customize:

```hcl
# AWS Configuration
aws_region = "us-west-2"

# Project Configuration
project_name = "django-nextjs-app"
environment  = "dev"

# Docker Images (update with your ECR URLs)
backend_image  = "123456789012.dkr.ecr.us-west-2.amazonaws.com/django-nextjs-app-dev-backend:latest"
frontend_image = "123456789012.dkr.ecr.us-west-2.amazonaws.com/django-nextjs-app-dev-frontend:latest"

# Backend Environment Variables
backend_environment_variables = {
  DEBUG = "False"
  SECRET_KEY = "your-secret-key"
  DATABASE_URL = "your-database-url"
}
```

### SSL Certificate (Optional)

To enable HTTPS:

1. Request a certificate in AWS Certificate Manager
2. Add the certificate ARN to `terraform.tfvars`:

```hcl
certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/your-cert-id"
domain_name = "your-domain.com"
```

### Custom Domain (Optional)

To use a custom domain:

1. Add your domain to Route 53
2. Create an alias record pointing to the ALB
3. Configure the certificate for your domain

## Scaling

### Auto Scaling
The ECS services are configured with desired capacity. To enable auto-scaling:

1. Modify the Terraform configuration
2. Add CloudWatch alarms
3. Configure ECS service auto-scaling policies

### Resource Allocation
Adjust CPU and memory in `terraform.tfvars`:

```hcl
# In terraform/main.tf, modify the ECS module:
backend_cpu     = 512  # Increase for more performance
backend_memory  = 1024
frontend_cpu    = 256
frontend_memory = 512

desired_count_backend  = 3  # Scale to more instances
desired_count_frontend = 2
```

## Monitoring

### CloudWatch Logs
Logs are automatically sent to CloudWatch:
- Backend logs: `/ecs/django-nextjs-app-dev-backend`
- Frontend logs: `/ecs/django-nextjs-app-dev-frontend`

### Health Checks
- Backend health check: `/health/`
- Frontend health check: `/` (root path)

## Security

### Network Security
- ALB in public subnets
- ECS tasks in private subnets
- Security groups restrict access:
  - ALB: ports 80/443 from internet
  - ECS tasks: only from ALB

### IAM Roles
- ECS Task Execution Role: Pull images, send logs
- ECS Task Role: Application permissions

## Troubleshooting

### Common Issues

1. **Images not found**
   - Ensure images are pushed to ECR
   - Check image URLs in terraform.tfvars

2. **ECS tasks failing**
   - Check CloudWatch logs
   - Verify environment variables
   - Check health check endpoints

3. **ALB health checks failing**
   - Ensure Django `/health/` endpoint works
   - Check security group rules
   - Verify container ports

### Debugging Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster django-nextjs-app-dev --services django-nextjs-app-dev-backend

# View ECS task logs
aws logs get-log-events --log-group-name /ecs/django-nextjs-app-dev-backend --log-stream-name ecs/backend/task-id

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...
```

## Cost Optimization

### Development Environment
- Use FARGATE_SPOT for non-production
- Single NAT Gateway
- Smaller instance sizes

### Production Environment
- Multiple AZs for high availability
- Reserved capacity for predictable workloads
- CloudWatch monitoring and alerting

## Cleanup

To destroy all resources:

```bash
./deploy.sh destroy
```

Or manually:

```bash
cd terraform
terraform destroy
```

**Note**: This will delete all resources including data. Make sure to backup any important data first.

## Module Structure

```
terraform/
├── modules/
│   ├── ecr/           # ECR repositories
│   ├── vpc/           # VPC, subnets, gateways
│   └── ecs/           # ECS cluster, services, ALB
├── main.tf            # Main configuration
├── variables.tf       # Input variables
├── outputs.tf         # Output values
└── terraform.tfvars   # Variable values
```

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review AWS ECS console
3. Verify Terraform state
4. Check security group rules

## License

This project is licensed under the MIT License.
