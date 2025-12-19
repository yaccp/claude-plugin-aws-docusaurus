# AWS Static Site Templates

Reusable templates for deploying static sites on AWS with S3 + CloudFront.

## Complete Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW COMPLET                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. docusaurus-init          Créer le projet Docusaurus         │
│         │                                                       │
│         ▼                                                       │
│  2. aws-static-site-infra    Créer l'infrastructure AWS         │
│         │                    (S3, CloudFront, Lambda, DNS)      │
│         ▼                                                       │
│  3. aws-static-site-deploy   Déployer le contenu                │
│         │                    (Build + S3 sync + Invalidation)   │
│         ▼                                                       │
│      SITE LIVE              https://votre-site.example.com      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Set Environment Variables

```bash
export SITE_NAME="my-awesome-site"
export DOMAIN="site.example.com"
export HOSTED_ZONE_ID="Z1234567890ABC"
export AWS_PROFILE="default"
export AWS_REGION="eu-west-3"

# Optional: For Basic Authentication
export AUTH_USERNAME="admin"
export AUTH_PASSWORD="SecurePassword123!"
```

### 2. Create Infrastructure

Follow the steps in `../../agents/aws-static-site-infra.md`

### 3. Deploy Content

Copy `deploy.template.sh` to your project, configure it, and run:

```bash
cp deploy.template.sh /path/to/your/project/deploy.sh
chmod +x /path/to/your/project/deploy.sh
./deploy.sh
```

## Template Files

| File | Description |
|------|-------------|
| `cloudfront-config.template.json` | CloudFront distribution configuration |
| `s3-bucket-policy.template.json` | S3 bucket policy for OAI access |
| `route53-alias.template.json` | DNS alias record configuration |
| `lambda/basic-auth.template.js` | Lambda@Edge Basic Auth function |
| `lambda/trust-policy.json` | IAM trust policy for Lambda@Edge |
| `deploy.template.sh` | Deployment script with caching |

## Variables Reference

| Variable | Used In | Description |
|----------|---------|-------------|
| `${SITE_NAME}` | All | Project identifier for resource naming |
| `${DOMAIN}` | CloudFront, Route53 | Custom domain name |
| `${AWS_REGION}` | CloudFront, S3 | Primary AWS region |
| `${OAI_ID}` | CloudFront | CloudFront Origin Access Identity ID |
| `${OAI_CANONICAL_USER_ID}` | S3 Policy | OAI canonical user for S3 permissions |
| `${ACM_CERTIFICATE_ARN}` | CloudFront | ACM certificate ARN (us-east-1) |
| `${LAMBDA_VERSION_ARN}` | CloudFront | Lambda@Edge version ARN |
| `${CLOUDFRONT_DOMAIN}` | Route53 | CloudFront distribution domain |
| `${S3_BUCKET}` | Deploy script | S3 bucket name |
| `${CLOUDFRONT_DISTRIBUTION_ID}` | Deploy script | CloudFront distribution ID |
| `${AUTH_USERNAME}` | Lambda | Basic Auth username |
| `${AUTH_PASSWORD}` | Lambda | Basic Auth password |

## Related Agents

| Agent | Description |
|-------|-------------|
| `docusaurus-init.md` | Initialise un projet Docusaurus prêt pour AWS |
| `aws-static-site-infra.md` | Crée l'infrastructure AWS (S3, CloudFront, Lambda@Edge, ACM, Route53) |
| `aws-static-site-deploy.md` | Déploie le contenu avec stratégie de cache optimale |

## Example: Full Deployment

```bash
# Step 1: Create Docusaurus project
export PROJECT_NAME="my-docs"
export SITE_TITLE="My Documentation"
export SITE_URL="https://docs.example.com"
npx create-docusaurus@latest ${PROJECT_NAME} classic --typescript
cd ${PROJECT_NAME}
# Configure docusaurus.config.ts per docusaurus-init agent

# Step 2: Create AWS infrastructure
export SITE_NAME="my-docs"
export DOMAIN="docs.example.com"
export HOSTED_ZONE_ID="Z1234567890"
export AUTH_USERNAME="admin"
export AUTH_PASSWORD="SecretPass123!"
# Follow aws-static-site-infra agent steps
# Output: S3_BUCKET, CLOUDFRONT_DISTRIBUTION_ID

# Step 3: Deploy
export S3_BUCKET="my-docs"
export CLOUDFRONT_DISTRIBUTION_ID="E1234567890ABC"
./deploy.sh

# Result: https://docs.example.com (protected by Basic Auth)
```
