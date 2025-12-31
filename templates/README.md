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

# Get AWS Account ID (required for S3 bucket naming)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# S3 bucket name follows convention: ${SITE_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}
export S3_BUCKET="${SITE_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}"

# Optional: For Basic Authentication
export AUTH_USERNAME="admin"
export AUTH_PASSWORD="SecurePassword123!"
```

### 1b. Check for Existing ACM Certificate

```bash
# List certificates in us-east-1 (required for CloudFront)
aws acm list-certificates --region us-east-1 --output table

# Check for wildcard matching your domain
PARENT_DOMAIN=$(echo $DOMAIN | sed 's/^[^.]*\.//')
aws acm list-certificates --region us-east-1 \
  --query "CertificateSummaryList[?DomainName=='*.${PARENT_DOMAIN}'].CertificateArn" \
  --output text

# If found, set it:
export ACM_CERTIFICATE_ARN="arn:aws:acm:us-east-1:${AWS_ACCOUNT_ID}:certificate/xxx"
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

## Naming Conventions

### S3 Bucket Naming

Les buckets S3 **doivent** être suffixés par l'account ID et la région pour garantir l'unicité globale :

```
${SITE_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}
```

Exemple : `my-docs-123456789012-eu-west-3`

Pour obtenir l'account ID :
```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

### ACM Certificate Reuse

Avant de créer un nouveau certificat ACM, **vérifiez si un certificat existant peut être réutilisé** :

```bash
# Lister les certificats existants dans us-east-1 (requis pour CloudFront)
aws acm list-certificates --region us-east-1 --query 'CertificateSummaryList[*].[DomainName,CertificateArn]' --output table

# Vérifier si un wildcard certificate existe pour votre domaine
aws acm list-certificates --region us-east-1 --query "CertificateSummaryList[?contains(DomainName, '*.example.com')]"
```

**Règles de réutilisation :**
- Un certificat `*.example.com` couvre `site.example.com`, `docs.example.com`, etc.
- Un certificat peut avoir plusieurs SANs (Subject Alternative Names)
- Privilégier la réutilisation pour éviter les limites ACM (défaut: 2500 certificats/compte)

## Variables Reference

| Variable | Used In | Description |
|----------|---------|-------------|
| `${SITE_NAME}` | All | Project identifier for resource naming |
| `${AWS_ACCOUNT_ID}` | S3 | AWS Account ID (12 digits) |
| `${DOMAIN}` | CloudFront, Route53 | Custom domain name |
| `${AWS_REGION}` | CloudFront, S3 | Primary AWS region |
| `${OAI_ID}` | CloudFront | CloudFront Origin Access Identity ID |
| `${OAI_CANONICAL_USER_ID}` | S3 Policy | OAI canonical user for S3 permissions |
| `${ACM_CERTIFICATE_ARN}` | CloudFront | ACM certificate ARN (us-east-1) |
| `${LAMBDA_VERSION_ARN}` | CloudFront | Lambda@Edge version ARN |
| `${CLOUDFRONT_DOMAIN}` | Route53 | CloudFront distribution domain |
| `${S3_BUCKET}` | Deploy script | S3 bucket name (`${SITE_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}`) |
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
