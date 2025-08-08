# GitHub Actions Configuration Template
# Copy this content to configure your GitHub repository

## Required Repository Secrets
# Go to Settings > Secrets and variables > Actions

### AWS Configuration
AWS_ACCESS_KEY_ID=your_aws_access_key_id_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key_here

### Monitoring Configuration  
ALERT_EMAIL=your-alert-email@company.com

### Optional: Slack Integration
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK

## Required Environment Configuration
# Go to Settings > Environments and create these environments:

### Development Environment
# Name: dev
# Protection rules:
#   - Required reviewers: 0
#   - Wait timer: 0 minutes
#   - Allowed branches: develop, main

### Staging Environment  
# Name: staging
# Protection rules:
#   - Required reviewers: 1 (optional)
#   - Wait timer: 0 minutes
#   - Allowed branches: develop, main

### Production Environment
# Name: prod  
# Protection rules:
#   - Required reviewers: 2
#   - Wait timer: 5 minutes
#   - Allowed branches: main only

### Cleanup Environments (for safe destruction)
# Name: dev-cleanup
# Protection rules:
#   - Required reviewers: 1
#   - Allowed branches: main

# Name: staging-cleanup  
# Protection rules:
#   - Required reviewers: 1
#   - Allowed branches: main

# Name: prod-cleanup
# Protection rules:
#   - Required reviewers: 2
#   - Allowed branches: main

## Branch Protection Rules
# Go to Settings > Branches

### Main Branch Protection
# Branch name: main
# Protections:
#   ✅ Require a pull request before merging
#   ✅ Require approvals (2)
#   ✅ Dismiss stale PR approvals when new commits are pushed
#   ✅ Require status checks to pass before merging
#   ✅ Require branches to be up to date before merging
#   ✅ Required status checks:
#       - test-and-build
#   ✅ Require conversation resolution before merging
#   ✅ Include administrators

### Develop Branch Protection
# Branch name: develop
# Protections:
#   ✅ Require a pull request before merging
#   ✅ Require approvals (1)
#   ✅ Require status checks to pass before merging
#   ✅ Required status checks:
#       - test-and-build

## Workflow Configuration

### Automatic Triggers
# The pipelines are configured to trigger automatically:
# - Push to 'main' → Production deployment
# - Push to 'develop' → Staging deployment  
# - Pull requests → Build and test only

### Manual Triggers
# All workflows support manual dispatch:
# - Deploy workflow: Choose environment and force options
# - Promote workflow: Select source and target environments
# - Cleanup workflow: Choose environment and confirm destruction
# - Health check workflow: Select environment and detail level

## AWS Prerequisites

### IAM User/Role Permissions
# The AWS credentials need the following permissions:

### EC2 Permissions
# - ec2:*
# - vpc:*
# - elasticloadbalancing:*

### ECS Permissions  
# - ecs:*
# - application-autoscaling:*

### ECR Permissions
# - ecr:*

### CloudWatch Permissions
# - cloudwatch:*
# - logs:*
# - sns:*

### IAM Permissions
# - iam:CreateRole
# - iam:CreatePolicy
# - iam:AttachRolePolicy
# - iam:PassRole
# - iam:GetRole
# - iam:ListRoles

### Route53 Permissions (if using custom domains)
# - route53:*

## Setup Checklist

### Repository Setup
- [ ] Add all required secrets
- [ ] Configure environments with protection rules
- [ ] Set up branch protection
- [ ] Test AWS credentials

### AWS Setup  
- [ ] Verify IAM permissions
- [ ] Check AWS account limits
- [ ] Configure any custom domains
- [ ] Set up billing alerts

### Initial Deployment
- [ ] Test deploy workflow manually
- [ ] Verify all environments work
- [ ] Check monitoring and alerts
- [ ] Test promotion workflow

### Documentation
- [ ] Update README with deployment URLs
- [ ] Document any custom configurations
- [ ] Share access with team members
- [ ] Set up monitoring dashboards

## Customization Options

### Environment Variables
# Modify these in the workflow files if needed:
AWS_REGION=us-west-2
PROJECT_NAME=django-nextjs-app

### Resource Sizing
# Adjust in the deploy workflow:
# - CPU and memory allocations
# - Auto-scaling settings
# - Alarm thresholds

### Monitoring
# Configure alert thresholds:
# - CPU usage alerts
# - Memory usage alerts  
# - Response time alerts
# - Error rate alerts

### Deployment Strategy
# Options to consider:
# - Blue-green deployments
# - Canary deployments
# - Rolling updates
# - Maintenance windows

## Getting Started

1. **Configure Repository:**
   ```bash
   # Add secrets and environments as described above
   ```

2. **Test Pipeline:**
   ```bash
   # Trigger a manual deployment to dev environment
   # Go to Actions > Deploy to AWS ECS > Run workflow
   ```

3. **Verify Setup:**
   ```bash
   # Check health monitoring
   # Go to Actions > Health Check & Monitoring > Run workflow  
   ```

4. **Deploy to Production:**
   ```bash
   # Merge to main branch or use manual promotion
   ```

For detailed usage instructions, see: docs/CICD_PIPELINE.md
