#!/bin/bash

# Deployment script for Django + Next.js application to AWS ECS
# This script will:
# 1. Build and push Docker images to ECR
# 2. Deploy infrastructure using Terraform
# 3. Update ECS services with new images

set -e

# Configuration
AWS_REGION=${AWS_REGION:-"us-west-2"}
PROJECT_NAME=${PROJECT_NAME:-"django-nextjs-app"}
ENVIRONMENT=${ENVIRONMENT:-"dev"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    log_info "All dependencies are installed"
}

# Get AWS account ID
get_aws_account_id() {
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        log_error "Failed to get AWS account ID"
        exit 1
    fi
    log_info "AWS Account ID: $AWS_ACCOUNT_ID"
}

# Create ECR repositories first
create_ecr_repositories() {
    log_info "Creating ECR repositories..."
    
    # Check if backend repository exists
    if ! aws ecr describe-repositories --repository-names "${PROJECT_NAME}-${ENVIRONMENT}-backend" --region "$AWS_REGION" &> /dev/null; then
        log_info "Creating backend ECR repository..."
        aws ecr create-repository \
            --repository-name "${PROJECT_NAME}-${ENVIRONMENT}-backend" \
            --region "$AWS_REGION" \
            --image-scanning-configuration scanOnPush=true
    else
        log_info "Backend ECR repository already exists"
    fi
    
    # Check if frontend repository exists
    if ! aws ecr describe-repositories --repository-names "${PROJECT_NAME}-${ENVIRONMENT}-frontend" --region "$AWS_REGION" &> /dev/null; then
        log_info "Creating frontend ECR repository..."
        aws ecr create-repository \
            --repository-name "${PROJECT_NAME}-${ENVIRONMENT}-frontend" \
            --region "$AWS_REGION" \
            --image-scanning-configuration scanOnPush=true
    else
        log_info "Frontend ECR repository already exists"
    fi
}

# Build and push Docker images
build_and_push_images() {
    log_info "Building and pushing Docker images..."
    
    # Login to ECR
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    
    # Build and push backend image
    log_info "Building backend image..."
    docker build -t "${PROJECT_NAME}-backend" -f Dockerfile .
    docker tag "${PROJECT_NAME}-backend:latest" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-${ENVIRONMENT}-backend:latest"
    
    log_info "Pushing backend image..."
    docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-${ENVIRONMENT}-backend:latest"
    
    # Build and push frontend image
    log_info "Building frontend image..."
    docker build -t "${PROJECT_NAME}-frontend" -f menu-frontend/Dockerfile.frontend menu-frontend/
    docker tag "${PROJECT_NAME}-frontend:latest" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-${ENVIRONMENT}-frontend:latest"
    
    log_info "Pushing frontend image..."
    docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-${ENVIRONMENT}-frontend:latest"
    
    log_info "Docker images pushed successfully"
}

# Initialize Terraform
init_terraform() {
    log_info "Initializing Terraform..."
    cd terraform
    terraform init
    cd ..
}

# Create terraform.tfvars file
create_tfvars() {
    log_info "Creating terraform.tfvars file..."
    
    cat > terraform/terraform.tfvars <<EOF
aws_region = "$AWS_REGION"
project_name = "$PROJECT_NAME"
environment = "$ENVIRONMENT"

backend_environment_variables = {
  DEBUG = "False"
}

default_tags = {
  Project     = "$PROJECT_NAME"
  Environment = "$ENVIRONMENT"
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
EOF
    
    log_info "terraform.tfvars file created"
}

# Deploy infrastructure
deploy_infrastructure() {
    log_info "Deploying infrastructure with Terraform..."
    cd terraform
    
    # Plan
    log_info "Running terraform plan..."
    terraform plan -out=tfplan
    
    # Apply
    log_info "Running terraform apply..."
    terraform apply tfplan
    
    # Get outputs
    log_info "Getting Terraform outputs..."
    terraform output
    
    cd ..
}

# Main deployment function
deploy() {
    log_info "Starting deployment..."
    
    check_dependencies
    get_aws_account_id
    create_ecr_repositories
    build_and_push_images
    init_terraform
    create_tfvars
    deploy_infrastructure
    
    log_info "Deployment completed successfully!"
    log_info "Your application should be available at the ALB DNS name shown in the Terraform outputs"
}

# Destroy infrastructure
destroy() {
    log_warn "Destroying infrastructure..."
    
    # Clean up ECR repositories first
    log_info "Cleaning up ECR repositories before destroy..."
    ./cleanup-ecr.sh cleanup
    
    cd terraform
    terraform destroy
    cd ..
    log_info "Infrastructure destroyed"
}

# Clean ECR only
clean_ecr() {
    log_info "Cleaning ECR repositories..."
    ./cleanup-ecr.sh cleanup
}

# Check pipeline status
check_pipeline() {
    log_info "Checking GitHub Actions pipeline status..."
    
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI not installed. Please install 'gh' to check pipeline status."
        log_info "You can check manually at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
        return
    fi
    
    # Get recent workflow runs
    log_info "Recent workflow runs:"
    gh run list --limit 5
    
    # Check if any workflows are currently running
    RUNNING_WORKFLOWS=$(gh run list --status in_progress --json workflowName,status | jq -r '.[] | "\(.workflowName): \(.status)"')
    
    if [ -n "$RUNNING_WORKFLOWS" ]; then
        log_info "Currently running workflows:"
        echo "$RUNNING_WORKFLOWS"
    else
        log_info "No workflows currently running"
    fi
}

# Trigger pipeline deployment
trigger_deploy() {
    local environment=${1:-"dev"}
    
    log_info "Triggering pipeline deployment for environment: $environment"
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI not installed. Please install 'gh' to trigger deployments."
        exit 1
    fi
    
    # Trigger the deployment workflow
    gh workflow run deploy.yml -f action="deploy" -f environment="$environment"
    
    log_info "Deployment triggered. Check status with: $0 pipeline-status"
}

# Promote environment
promote_env() {
    local source_env=${1:-"dev"}
    local target_env=${2:-"staging"}
    
    log_info "Promoting from $source_env to $target_env"
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI not installed. Please install 'gh' to trigger promotions."
        exit 1
    fi
    
    # Trigger the promotion workflow
    gh workflow run deploy.yml -f action="promote" -f source_environment="$source_env" -f target_environment="$target_env"
    
    log_info "Environment promotion triggered. Check status with: $0 pipeline-status"
}

# Trigger cleanup
cleanup_pipeline() {
    local environment=${1:-"dev"}
    
    log_warn "Triggering pipeline cleanup for environment: $environment"
    log_warn "This will destroy all infrastructure in the $environment environment!"
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI not installed. Please install 'gh' to trigger cleanup."
        exit 1
    fi
    
    # Confirm destruction
    read -p "Type 'DESTROY' to confirm: " confirmation
    if [[ "$confirmation" != "DESTROY" ]]; then
        log_error "Cleanup cancelled. Must type 'DESTROY' to confirm."
        exit 1
    fi
    
    # Trigger the cleanup workflow
    gh workflow run deploy.yml -f action="cleanup" -f environment="$environment" -f confirm_destroy="DESTROY"
    
    log_info "Infrastructure cleanup triggered. Check status with: $0 pipeline-status"
}

# Trigger health check
health_check_pipeline() {
    local environment=${1:-"prod"}
    
    log_info "Triggering health check for environment: $environment"
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI not installed. Please install 'gh' to trigger health checks."
        exit 1
    fi
    
    # Trigger the health check
    gh workflow run deploy.yml -f action="health-check" -f environment="$environment"
    
    log_info "Health check triggered. Check status with: $0 pipeline-status"
}

# Show help function
show_help() {
    cat <<EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
    deploy                  Deploy the complete infrastructure and application locally
    destroy                 Destroy the infrastructure (includes ECR cleanup)
    clean-ecr              Clean ECR repositories only
    pipeline-status        Check GitHub Actions pipeline status
    trigger-deploy [ENV]   Trigger pipeline deployment (ENV: dev|staging|prod)
    promote SOURCE TARGET  Promote between environments (dev→staging, staging→prod)
    cleanup-pipeline [ENV] Trigger pipeline cleanup (DANGEROUS!)
    health-check [ENV]     Trigger pipeline health check
    help                   Show this help message

Local Deployment:
    $0 deploy              # Deploy using local tools

Pipeline Operations:
    $0 trigger-deploy      # Trigger dev deployment via pipeline
    $0 trigger-deploy prod # Trigger prod deployment via pipeline
    $0 promote dev staging # Promote dev to staging via pipeline
    $0 cleanup-pipeline dev # Cleanup dev environment via pipeline
    $0 health-check prod   # Health check prod environment

Infrastructure Management:
    $0 destroy             # Destroy infrastructure locally
    $0 clean-ecr           # Clean ECR before manual terraform destroy

Monitoring:
    $0 pipeline-status     # Check pipeline status

Environment Variables:
    AWS_REGION      AWS region (default: us-west-2)
    PROJECT_NAME    Project name (default: django-nextjs-app)
    ENVIRONMENT     Environment (default: dev)

Examples:
    $0 deploy                           # Local deployment
    $0 trigger-deploy staging           # Pipeline deployment to staging
    $0 promote dev staging              # Promote dev to staging via pipeline
    $0 health-check prod               # Check production health
    $0 cleanup-pipeline dev            # Cleanup dev environment
    $0 clean-ecr                       # Clean ECR before destroy
    $0 destroy                         # Destroy infrastructure locally

Single Pipeline Features:
    - Unified workflow handling all operations (deploy, promote, cleanup, health-check)
    - Environment-specific configurations
    - Conditional job execution based on action
    - Comprehensive monitoring and alerting
    - ECR cleanup integration
    - Health checks and deployment verification

Prerequisites:
    - AWS CLI configured with appropriate credentials
    - Terraform installed
    - Docker installed
    - GitHub CLI (gh) for pipeline operations
    - GitHub repository secrets configured:
      * AWS_ACCESS_KEY_ID
      * AWS_SECRET_ACCESS_KEY
      * ALERT_EMAIL
EOF
}

# Main script logic
case "${1:-}" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    clean-ecr)
        clean_ecr
        ;;
    pipeline-status)
        check_pipeline
        ;;
    trigger-deploy)
        trigger_deploy "${2:-dev}"
        ;;
    promote)
        if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
            log_error "Promote requires source and target environments"
            log_info "Usage: $0 promote SOURCE TARGET"
            log_info "Example: $0 promote dev staging"
            exit 1
        fi
        promote_env "$2" "$3"
        ;;
    cleanup-pipeline)
        cleanup_pipeline "${2:-dev}"
        ;;
    health-check)
        health_check_pipeline "${2:-prod}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: ${1:-}"
        show_help
        exit 1
        ;;
esac
