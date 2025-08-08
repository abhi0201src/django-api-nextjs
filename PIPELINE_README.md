# Single Pipeline CI/CD Setup

This project uses a single, unified GitHub Actions workflow to handle all CI/CD operations.

## 🔧 Quick Setup

### 1. GitHub Secrets
Add these secrets to your repository:
```
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
DJANGO_SECRET_KEY=your_django_secret_key
ALERT_EMAIL=your-email@company.com
```

**Security Note**: See `SECRETS_SETUP.md` for detailed setup instructions and security best practices.

### 2. GitHub Environments
Create these environments in your repository settings:
- `dev`
- `staging` 
- `prod`
- `dev-cleanup`
- `staging-cleanup`
- `prod-cleanup`

## 🚀 How to Use

### Automatic Deployments
- **Push to `main`** → Deploys to production
- **Push to `develop`** → Deploys to staging
- **Pull requests** → Runs tests only

### Manual Operations
Go to **Actions** → **CI/CD Pipeline** → **Run workflow**

#### Deploy
- **Action**: deploy
- **Environment**: dev/staging/prod

#### Promote
- **Action**: promote
- **Source**: dev/staging
- **Target**: staging/prod

#### Cleanup (DANGEROUS!)
- **Action**: cleanup
- **Environment**: environment to destroy
- **Confirm**: Type "DESTROY"

#### Health Check
- **Action**: health-check
- **Environment**: environment to check

## 🖥️ Local Commands

```bash
# Local deployment
./deploy.sh deploy

# Pipeline operations
./deploy.sh trigger-deploy dev
./deploy.sh promote dev staging
./deploy.sh cleanup-pipeline dev
./deploy.sh health-check prod

# Status and maintenance
./deploy.sh pipeline-status
./deploy.sh clean-ecr
```

## 📋 Pipeline Jobs

The single workflow intelligently runs only the jobs needed for each action:

| Action | Jobs That Run |
|--------|---------------|
| deploy | setup → test-build → deploy → health-check → summary |
| promote | setup → promote → health-check → summary |
| cleanup | setup → cleanup → summary |
| health-check | setup → health-check → summary |
| test-only (PR) | setup → test-build → summary |

## 🔍 Key Features

✅ **Single workflow file** - Easy to maintain  
✅ **Conditional execution** - Only runs necessary jobs  
✅ **Multi-environment** - dev, staging, prod support  
✅ **Safe promotions** - Validates promotion paths  
✅ **ECR management** - Automatic cleanup integration  
✅ **Health monitoring** - Post-deployment verification  
✅ **Security scanning** - Bandit and Safety checks  
✅ **Infrastructure as Code** - Full Terraform automation  

## 🛡️ Safety Features

- **Environment protection** - Requires approvals for prod
- **Confirmation required** - Must type "DESTROY" for cleanup
- **Validation checks** - Prevents invalid operations
- **Health verification** - Ensures deployments work
- **Rollback capability** - Previous images remain tagged

## 📊 Monitoring

- **CloudWatch integration** - Comprehensive metrics and alarms
- **Email alerts** - Notifications on issues
- **Dashboard** - Visual monitoring in AWS Console
- **Health endpoints** - Automated application checks

This single pipeline handles everything you need for a production-ready CI/CD workflow!
