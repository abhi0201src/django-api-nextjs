# GitHub Secrets Setup

To run the CI/CD pipeline successfully, you need to configure the following secrets in your GitHub repository:

## Required Secrets

Go to **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### 1. AWS Credentials
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 2. Django Configuration
```
DJANGO_SECRET_KEY
```
Generate a secure secret key for Django. You can use:
```python
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
```

### 3. Alert Email
```
ALERT_EMAIL
```
Email address for CloudWatch alerts (e.g., `your-email@example.com`)

## How to Add Secrets

1. Go to your repository on GitHub
2. Click **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret with the exact name and value

## Environment Variables in Deployment

The pipeline will automatically set these environment variables in your ECS containers:

- `DEBUG=False` (production mode)
- `ENVIRONMENT=dev/staging/prod` (based on target environment)
- `DJANGO_SECRET_KEY` (from GitHub secret)

## Security Notes

- Never commit secrets to your repository
- Use different secret keys for different environments
- Rotate your AWS credentials regularly
- The Django secret key should be a long, random string
