#!/bin/bash

# Setup and validation script for Django + Next.js ECS deployment
# This script validates your setup before deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${BLUE}=== $1 ===${NC}"; }

# Check if running from project root
check_project_root() {
    if [[ ! -f "manage.py" ]] || [[ ! -d "menu-frontend" ]] || [[ ! -d "terraform" ]]; then
        log_error "Please run this script from the project root directory"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    log_header "Checking Dependencies"
    
    local missing=0
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed"
        echo "Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        missing=1
    else
        log_info "AWS CLI: $(aws --version)"
    fi
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed"
        echo "Install: https://developer.hashicorp.com/terraform/downloads"
        missing=1
    else
        log_info "Terraform: $(terraform version -json | jq -r .terraform_version)"
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        echo "Install: https://docs.docker.com/get-docker/"
        missing=1
    else
        log_info "Docker: $(docker --version)"
    fi
    
    if ! command -v jq &> /dev/null; then
        log_warn "jq is not installed (recommended for JSON parsing)"
        echo "Install: sudo apt-get install jq (or brew install jq on macOS)"
    else
        log_info "jq: $(jq --version)"
    fi
    
    if [[ $missing -eq 1 ]]; then
        log_error "Missing required dependencies. Please install them and try again."
        exit 1
    fi
    
    log_info "All required dependencies are installed!"
}

# Check AWS configuration
check_aws_config() {
    log_header "Checking AWS Configuration"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        echo "Run: aws configure"
        echo "Or set environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    
    local aws_account=$(aws sts get-caller-identity --query Account --output text)
    local aws_user=$(aws sts get-caller-identity --query Arn --output text)
    local aws_region=$(aws configure get region || echo "us-west-2")
    
    log_info "AWS Account: $aws_account"
    log_info "AWS User/Role: $aws_user"
    log_info "AWS Region: $aws_region"
    
    # Check if region is set
    if [[ -z "$aws_region" ]]; then
        log_warn "AWS region not set. Using us-west-2 as default."
        export AWS_DEFAULT_REGION=us-west-2
    fi
}

# Check project structure
check_project_structure() {
    log_header "Checking Project Structure"
    
    local files=(
        "manage.py"
        "requirements.txt"
        "Dockerfile"
        "menu-frontend/package.json"
        "menu-frontend/Dockerfile.frontend"
        "terraform/main.tf"
        "terraform/variables.tf"
        "deploy.sh"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_info "✓ $file"
        else
            log_error "✗ $file (missing)"
        fi
    done
}

# Test Django application
test_django() {
    log_header "Testing Django Application"
    
    if [[ ! -d "venv" ]]; then
        log_warn "Virtual environment not found. Creating one..."
        python3 -m venv venv
    fi
    
    log_info "Activating virtual environment and installing dependencies..."
    source venv/bin/activate
    pip install -q -r requirements.txt
    
    log_info "Running Django system check..."
    python manage.py check
    
    log_info "Running Django tests..."
    python manage.py test
    
    log_info "Testing health endpoint..."
    python manage.py runserver 8000 &
    local django_pid=$!
    sleep 3
    
    if curl -s http://localhost:8000/health/ | grep -q "ok"; then
        log_info "✓ Health endpoint working"
    else
        log_error "✗ Health endpoint not working"
    fi
    
    kill $django_pid 2>/dev/null || true
    wait $django_pid 2>/dev/null || true
}

# Test Next.js application
test_nextjs() {
    log_header "Testing Next.js Application"
    
    cd menu-frontend
    
    if [[ ! -d "node_modules" ]]; then
        log_info "Installing Node.js dependencies..."
        npm install
    fi
    
    log_info "Building Next.js application..."
    npm run build
    
    log_info "✓ Next.js build successful"
    cd ..
}

# Test Docker builds
test_docker_builds() {
    log_header "Testing Docker Builds"
    
    log_info "Building backend Docker image..."
    if docker build -t test-backend . > /dev/null; then
        log_info "✓ Backend Docker build successful"
        docker rmi test-backend > /dev/null 2>&1 || true
    else
        log_error "✗ Backend Docker build failed"
    fi
    
    log_info "Building frontend Docker image..."
    if docker build -t test-frontend -f menu-frontend/Dockerfile.frontend menu-frontend/ > /dev/null; then
        log_info "✓ Frontend Docker build successful"
        docker rmi test-frontend > /dev/null 2>&1 || true
    else
        log_error "✗ Frontend Docker build failed"
    fi
}

# Validate Terraform
validate_terraform() {
    log_header "Validating Terraform Configuration"
    
    cd terraform
    
    log_info "Initializing Terraform..."
    terraform init > /dev/null
    
    log_info "Validating Terraform configuration..."
    terraform validate
    
    log_info "Formatting Terraform files..."
    terraform fmt -check=true
    
    log_info "✓ Terraform configuration is valid"
    cd ..
}

# Create example terraform.tfvars
create_example_tfvars() {
    log_header "Creating Example Configuration"
    
    if [[ ! -f "terraform/terraform.tfvars" ]]; then
        local aws_account=$(aws sts get-caller-identity --query Account --output text)
        local aws_region=$(aws configure get region || echo "us-west-2")
        
        cat > terraform/terraform.tfvars <<EOF
# AWS Configuration
aws_region = "$aws_region"

# Project Configuration
project_name = "django-nextjs-app"
environment  = "dev"

# Docker Images (update these after pushing to ECR)
backend_image  = "$aws_account.dkr.ecr.$aws_region.amazonaws.com/django-nextjs-app-dev-backend:latest"
frontend_image = "$aws_account.dkr.ecr.$aws_region.amazonaws.com/django-nextjs-app-dev-frontend:latest"

# Backend Environment Variables
backend_environment_variables = {
  DEBUG = "False"
}

# Default Tags
default_tags = {
  Project     = "django-nextjs-app"
  Environment = "dev"
  ManagedBy   = "terraform"
}
EOF
        log_info "Created terraform/terraform.tfvars with your AWS account details"
    else
        log_info "terraform/terraform.tfvars already exists"
    fi
}

# Show next steps
show_next_steps() {
    log_header "Next Steps"
    
    cat <<EOF
${GREEN}✅ Setup validation complete!${NC}

${YELLOW}To deploy your application:${NC}

1. Review and customize terraform/terraform.tfvars
2. Run the deployment:
   ${BLUE}./deploy.sh deploy${NC}

3. Or deploy manually:
   ${BLUE}# Create ECR repositories and push images
   aws ecr create-repository --repository-name django-nextjs-app-dev-backend
   aws ecr create-repository --repository-name django-nextjs-app-dev-frontend
   
   # Build and push images (see README for details)
   
   # Deploy infrastructure
   cd terraform
   terraform plan
   terraform apply${NC}

${YELLOW}For production deployment:${NC}
- Set up AWS Certificate Manager for HTTPS
- Configure a custom domain name
- Review security groups and IAM policies
- Set up monitoring and alerting

${YELLOW}Documentation:${NC}
- Full deployment guide: terraform/README.md
- GitHub Actions setup: .github/workflows/deploy.yml

${GREEN}Happy deploying! 🚀${NC}
EOF
}

# Main execution
main() {
    log_header "Django + Next.js ECS Deployment Setup"
    
    check_project_root
    check_dependencies
    check_aws_config
    check_project_structure
    test_django
    test_nextjs
    test_docker_builds
    validate_terraform
    create_example_tfvars
    show_next_steps
}

# Command line options
case "${1:-validate}" in
    validate|setup)
        main
        ;;
    deps|dependencies)
        check_dependencies
        ;;
    aws)
        check_aws_config
        ;;
    django)
        test_django
        ;;
    nextjs)
        test_nextjs
        ;;
    docker)
        test_docker_builds
        ;;
    terraform|tf)
        validate_terraform
        ;;
    help|--help|-h)
        cat <<EOF
Usage: $0 [COMMAND]

Commands:
    validate    Run all validation checks (default)
    deps        Check dependencies only
    aws         Check AWS configuration only
    django      Test Django application only
    nextjs      Test Next.js application only
    docker      Test Docker builds only
    terraform   Validate Terraform only
    help        Show this help

Examples:
    $0              # Run all checks
    $0 validate     # Run all checks
    $0 django       # Test Django only
    $0 terraform    # Validate Terraform only
EOF
        ;;
    *)
        log_error "Unknown command: $1"
        log_info "Run '$0 help' for usage information"
        exit 1
        ;;
esac
