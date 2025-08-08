# CI/CD Pipeline Documentation

This repository includes a comprehensive CI/CD pipeline for deploying a Django + Next.js application to AWS ECS using GitHub Actions and Terraform.

## 🚀 Pipeline Overview

The CI/CD pipeline consists of four main workflows:

### 1. Deploy Workflow (`.github/workflows/deploy.yml`)
**Triggers:** 
- Push to `main` (deploys to prod)
- Push to `develop` (deploys to staging) 
- Manual dispatch with environment selection

**Features:**
- Multi-environment support (dev, staging, prod)
- Automated testing (Django tests, security checks)
- Docker image building and pushing to ECR
- Infrastructure deployment with Terraform
- Health checks and deployment verification
- Environment-specific configurations
- Deployment summaries and notifications

### 2. Environment Promotion (`.github/workflows/promote.yml`)
**Triggers:** Manual dispatch only

**Features:**
- Promotes Docker images between environments
- Validates promotion paths (dev→staging→prod)
- Automated infrastructure updates
- Post-promotion health checks
- Deployment verification

### 3. Infrastructure Cleanup (`.github/workflows/cleanup.yml`)
**Triggers:** Manual dispatch only

**Features:**
- Safe infrastructure destruction
- ECR repository cleanup
- Confirmation requirements
- Environment-specific cleanup
- Detailed cleanup reporting

### 4. Health Monitoring (`.github/workflows/health-check.yml`)
**Triggers:** 
- Scheduled (every 30 minutes)
- Manual dispatch

**Features:**
- Automated health checks for all environments
- ECS service status monitoring
- Application endpoint testing
- CloudWatch alarm monitoring
- Alert generation on failures

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging     │    │   Production    │
│   Environment   │────│   Environment   │────│   Environment   │
│                 │    │                 │    │                 │
│  - Auto deploy  │    │  - Promoted     │    │  - Promoted     │
│    from develop │    │    from dev     │    │    from staging │
│  - Feature test │    │  - Integration  │    │  - Live traffic │
│  - Low resources│    │  - Full testing │    │  - High resources│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Setup Instructions

### 1. GitHub Repository Secrets

Configure the following secrets in your GitHub repository:

```bash
# AWS Credentials
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# Monitoring
ALERT_EMAIL=your-email@company.com
```

### 2. GitHub Environments

Create the following environments in your GitHub repository settings:

- `dev` - Development environment
- `staging` - Staging environment  
- `prod` - Production environment
- `dev-cleanup` - For development cleanup operations
- `staging-cleanup` - For staging cleanup operations
- `prod-cleanup` - For production cleanup operations

### 3. Repository Structure

Ensure your repository has the following structure:
```
.github/
  workflows/
    deploy.yml          # Main deployment pipeline
    promote.yml         # Environment promotion
    cleanup.yml         # Infrastructure cleanup
    health-check.yml    # Health monitoring
terraform/
  modules/
    vpc/               # VPC module
    ecr/               # ECR module
    ecs/               # ECS module
    iam/               # IAM module
    monitoring/        # CloudWatch monitoring
  main.tf              # Main Terraform configuration
menu-frontend/
  Dockerfile.frontend  # Frontend Docker configuration
Dockerfile             # Backend Docker configuration
deploy.sh              # Local deployment script
cleanup-ecr.sh         # ECR cleanup utility
```

## 🚦 Usage Guide

### Automated Deployments

#### Continuous Deployment
- **Development:** Push to `develop` branch → Auto-deploy to staging
- **Production:** Push to `main` branch → Auto-deploy to production

#### Manual Deployment
1. Go to **Actions** tab in GitHub
2. Select **Deploy to AWS ECS** workflow
3. Click **Run workflow**
4. Select environment and options
5. Click **Run workflow**

### Environment Promotion

#### Promote Development to Staging
1. Go to **Actions** tab
2. Select **Promote Environment** workflow
3. Set `source_environment: dev` and `target_environment: staging`
4. Click **Run workflow**

#### Promote Staging to Production
1. Go to **Actions** tab
2. Select **Promote Environment** workflow
3. Set `source_environment: staging` and `target_environment: prod`
4. Click **Run workflow**

### Local Operations

#### Using the Deploy Script
```bash
# Local deployment
./deploy.sh deploy

# Check pipeline status
./deploy.sh pipeline-status

# Trigger pipeline deployment
./deploy.sh trigger-deploy dev
./deploy.sh trigger-deploy staging
./deploy.sh trigger-deploy prod

# Promote environments
./deploy.sh promote dev staging
./deploy.sh promote staging prod

# Clean ECR repositories
./deploy.sh clean-ecr

# Destroy infrastructure
./deploy.sh destroy
```

## 📊 Monitoring and Alerts

### Health Checks
- **Automated:** Every 30 minutes via GitHub Actions
- **Manual:** Run health check workflow on-demand
- **Endpoints:** Health, Frontend, API endpoints
- **Services:** ECS service status monitoring

### CloudWatch Integration
- **Alarms:** CPU, Memory, Response time, Error rates
- **Dashboard:** Environment-specific dashboards
- **Notifications:** Email alerts via SNS

### Alert Conditions
- ECS service failures
- High CPU/Memory usage
- Application endpoint failures
- CloudWatch alarm triggers

## 🛡️ Security Features

### Code Security
- **Bandit:** Python security linting
- **Safety:** Dependency vulnerability scanning
- **ECR:** Container image scanning

### Access Control
- **GitHub Environments:** Protected deployments
- **IAM Roles:** Least privilege access
- **Secrets Management:** GitHub Secrets integration

### Compliance
- **Infrastructure as Code:** All resources managed by Terraform
- **Audit Trail:** GitHub Actions logs
- **Immutable Deployments:** Docker images with SHA tags

## 🔄 Workflow Details

### Deploy Workflow Steps
1. **Test and Build**
   - Run Django tests
   - Security scanning
   - Build Next.js application
   - Build and push Docker images

2. **Deploy Infrastructure**
   - Initialize Terraform
   - Plan infrastructure changes
   - Apply Terraform configuration
   - Update ECS services

3. **Health Check**
   - Wait for service stabilization
   - Test application endpoints
   - Generate deployment summary

4. **Notify**
   - Success/failure notifications
   - Deployment summaries

### Environment-Specific Configurations

#### Development
- **Resources:** Minimal (1 CPU, 512MB RAM)
- **Monitoring:** Basic alerts
- **Auto-scaling:** Disabled

#### Staging
- **Resources:** Medium (2 CPU, 1GB RAM)
- **Monitoring:** Full monitoring
- **Auto-scaling:** Enabled

#### Production
- **Resources:** High (3+ CPU, 2GB+ RAM)
- **Monitoring:** Comprehensive alerts
- **Auto-scaling:** Enabled with strict thresholds

## 🚨 Troubleshooting

### Common Issues

#### ECR Repository Cleanup
```bash
# Manual ECR cleanup
./cleanup-ecr.sh status
./cleanup-ecr.sh cleanup
./cleanup-ecr.sh force-destroy
```

#### Terraform State Issues
```bash
# Re-initialize Terraform
cd terraform
terraform init -reconfigure
```

#### Failed Deployments
1. Check GitHub Actions logs
2. Verify AWS credentials
3. Check resource limits
4. Review CloudWatch logs

#### Health Check Failures
1. Verify ALB DNS resolution
2. Check ECS service status
3. Review application logs
4. Test endpoints manually

### Getting Help

#### Logs and Monitoring
- **GitHub Actions:** Check workflow logs
- **CloudWatch:** Application and infrastructure logs  
- **AWS Console:** ECS, ALB, and ECR status

#### Commands for Debugging
```bash
# Check pipeline status
./deploy.sh pipeline-status

# Local health check
curl -f http://your-alb-dns/health/

# Check ECS services
aws ecs describe-services --cluster your-cluster --services your-service

# Check CloudWatch alarms
aws cloudwatch describe-alarms --state-value ALARM
```

## 📝 Best Practices

### Development Workflow
1. Create feature branches from `develop`
2. Test locally before pushing
3. Create pull requests for code review
4. Merge to `develop` for staging deployment
5. Promote to `main` for production

### Deployment Strategy
1. **Blue-Green Deployments:** ECS rolling updates
2. **Health Checks:** Always verify deployment health
3. **Rollback Plan:** Keep previous image tags
4. **Monitoring:** Watch metrics during deployment

### Security Practices
1. **Secrets:** Never commit secrets to code
2. **Access:** Use environment protection rules
3. **Images:** Scan for vulnerabilities
4. **Updates:** Keep dependencies updated

## 🔮 Future Enhancements

### Planned Features
- [ ] Slack/Teams integration for notifications
- [ ] Database migration automation
- [ ] Canary deployments
- [ ] Performance testing integration
- [ ] Cost optimization alerts
- [ ] Multi-region deployments

### Monitoring Improvements
- [ ] Custom application metrics
- [ ] Business KPI tracking
- [ ] SLA monitoring
- [ ] Capacity planning alerts

This CI/CD pipeline provides a robust, scalable, and secure deployment solution for your Django + Next.js application on AWS ECS.
