#!/bin/bash

# Script to clean up ECR repositories before destroying infrastructure
# This script will delete all images in ECR repositories to allow Terraform destroy to work

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

# Clean up ECR repositories
cleanup_ecr() {
    log_info "Cleaning up ECR repositories..."
    
    # Backend repository
    BACKEND_REPO="${PROJECT_NAME}-${ENVIRONMENT}-backend"
    if aws ecr describe-repositories --repository-names "$BACKEND_REPO" --region "$AWS_REGION" &> /dev/null; then
        log_info "Deleting images from backend repository: $BACKEND_REPO"
        
        # Get list of images
        IMAGES=$(aws ecr list-images --repository-name "$BACKEND_REPO" --region "$AWS_REGION" --query 'imageIds[*]' --output json)
        
        if [ "$IMAGES" != "[]" ]; then
            # Delete all images
            aws ecr batch-delete-image \
                --repository-name "$BACKEND_REPO" \
                --region "$AWS_REGION" \
                --image-ids "$IMAGES" > /dev/null
            log_info "Deleted all images from $BACKEND_REPO"
        else
            log_info "No images found in $BACKEND_REPO"
        fi
    else
        log_warn "Backend repository $BACKEND_REPO not found"
    fi
    
    # Frontend repository
    FRONTEND_REPO="${PROJECT_NAME}-${ENVIRONMENT}-frontend"
    if aws ecr describe-repositories --repository-names "$FRONTEND_REPO" --region "$AWS_REGION" &> /dev/null; then
        log_info "Deleting images from frontend repository: $FRONTEND_REPO"
        
        # Get list of images
        IMAGES=$(aws ecr list-images --repository-name "$FRONTEND_REPO" --region "$AWS_REGION" --query 'imageIds[*]' --output json)
        
        if [ "$IMAGES" != "[]" ]; then
            # Delete all images
            aws ecr batch-delete-image \
                --repository-name "$FRONTEND_REPO" \
                --region "$AWS_REGION" \
                --image-ids "$IMAGES" > /dev/null
            log_info "Deleted all images from $FRONTEND_REPO"
        else
            log_info "No images found in $FRONTEND_REPO"
        fi
    else
        log_warn "Frontend repository $FRONTEND_REPO not found"
    fi
    
    log_info "ECR cleanup completed"
}

# Force destroy ECR repositories
force_destroy_ecr() {
    log_warn "Force destroying ECR repositories..."
    
    # Backend repository
    BACKEND_REPO="${PROJECT_NAME}-${ENVIRONMENT}-backend"
    if aws ecr describe-repositories --repository-names "$BACKEND_REPO" --region "$AWS_REGION" &> /dev/null; then
        log_info "Force deleting backend repository: $BACKEND_REPO"
        aws ecr delete-repository --repository-name "$BACKEND_REPO" --region "$AWS_REGION" --force
    fi
    
    # Frontend repository
    FRONTEND_REPO="${PROJECT_NAME}-${ENVIRONMENT}-frontend"
    if aws ecr describe-repositories --repository-names "$FRONTEND_REPO" --region "$AWS_REGION" &> /dev/null; then
        log_info "Force deleting frontend repository: $FRONTEND_REPO"
        aws ecr delete-repository --repository-name "$FRONTEND_REPO" --region "$AWS_REGION" --force
    fi
    
    log_info "Force ECR destruction completed"
}

# List ECR repositories and their images
list_ecr_status() {
    log_info "ECR Repository Status:"
    
    # Backend repository
    BACKEND_REPO="${PROJECT_NAME}-${ENVIRONMENT}-backend"
    if aws ecr describe-repositories --repository-names "$BACKEND_REPO" --region "$AWS_REGION" &> /dev/null; then
        IMAGE_COUNT=$(aws ecr list-images --repository-name "$BACKEND_REPO" --region "$AWS_REGION" --query 'length(imageIds)')
        echo "  📦 $BACKEND_REPO: $IMAGE_COUNT images"
    else
        echo "  ❌ $BACKEND_REPO: Not found"
    fi
    
    # Frontend repository
    FRONTEND_REPO="${PROJECT_NAME}-${ENVIRONMENT}-frontend"
    if aws ecr describe-repositories --repository-names "$FRONTEND_REPO" --region "$AWS_REGION" &> /dev/null; then
        IMAGE_COUNT=$(aws ecr list-images --repository-name "$FRONTEND_REPO" --region "$AWS_REGION" --query 'length(imageIds)')
        echo "  📦 $FRONTEND_REPO: $IMAGE_COUNT images"
    else
        echo "  ❌ $FRONTEND_REPO: Not found"
    fi
}

# Help function
show_help() {
    cat <<EOF
Usage: $0 [COMMAND]

Commands:
    cleanup         Clean up ECR images (recommended before terraform destroy)
    force-destroy   Force delete ECR repositories completely
    status          Show current ECR repository status
    help            Show this help message

Environment Variables:
    AWS_REGION      AWS region (default: us-west-2)
    PROJECT_NAME    Project name (default: django-nextjs-app)
    ENVIRONMENT     Environment (default: dev)

Examples:
    $0 status                    # Check current status
    $0 cleanup                   # Clean images before terraform destroy
    $0 force-destroy            # Force delete repositories
    AWS_REGION=us-east-1 $0 cleanup
EOF
}

# Main script logic
case "${1:-}" in
    cleanup)
        cleanup_ecr
        ;;
    force-destroy)
        force_destroy_ecr
        ;;
    status)
        list_ecr_status
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
