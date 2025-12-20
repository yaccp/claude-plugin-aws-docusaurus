# AWS Docusaurus: Check Status

Check the status of your AWS infrastructure and recent deployments.

## Interactive Configuration

Before proceeding, check if required environment variables are set. If any are missing, ask the user for the values using AskUserQuestion.

### Required Variables Check

Check these environment variables and prompt for missing ones:

1. **CLOUDFRONT_DISTRIBUTION_ID** - CloudFront distribution ID (e.g., "E1234567890ABC")
2. **S3_BUCKET** - S3 bucket name (e.g., "my-site")
3. **AWS_PROFILE** - AWS CLI profile (default: "default")
4. **AWS_REGION** - AWS region (default: "eu-west-3")

### Optional Variables

- **DOMAIN** - Custom domain for health checks
- **SITE_NAME** - For Lambda@Edge status (if using auth)

## Execution Flow

1. Check environment variables
2. Use AskUserQuestion for any missing required variables
3. Run all status checks
4. Display summary with health indicators

## Status Checks to Perform

### 1. CloudFront Distribution Status

```bash
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query '{
    Status: Distribution.Status,
    DomainName: Distribution.DomainName,
    Enabled: Distribution.DistributionConfig.Enabled,
    PriceClass: Distribution.DistributionConfig.PriceClass,
    HttpVersion: Distribution.DistributionConfig.HttpVersion
  }'
```

Expected healthy output:
```json
{
  "Status": "Deployed",
  "DomainName": "d1234567890.cloudfront.net",
  "Enabled": true
}
```

### 2. S3 Bucket Status

```bash
# Check bucket exists and is accessible
aws s3api head-bucket --bucket ${S3_BUCKET}

# Get bucket size and object count
aws s3 ls s3://${S3_BUCKET}/ --recursive --summarize | tail -2

# List recent files
aws s3 ls s3://${S3_BUCKET}/ --recursive --human-readable | head -20
```

### 3. Recent Invalidations

```bash
aws cloudfront list-invalidations \
  --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'InvalidationList.Items[0:5].[Id,Status,CreateTime]' \
  --output table
```

### 4. Certificate Status

```bash
# Get certificate ARN from distribution
CERT_ARN=$(aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'Distribution.DistributionConfig.ViewerCertificate.ACMCertificateArn' \
  --output text)

# Check certificate status
aws acm describe-certificate \
  --region us-east-1 \
  --certificate-arn ${CERT_ARN} \
  --query '{
    Status: Certificate.Status,
    DomainName: Certificate.DomainName,
    NotAfter: Certificate.NotAfter,
    RenewalEligibility: Certificate.RenewalEligibility
  }'
```

### 5. Lambda@Edge Status (if using auth)

```bash
aws lambda get-function \
  --region us-east-1 \
  --function-name ${SITE_NAME}-basic-auth \
  --query '{
    Runtime: Configuration.Runtime,
    LastModified: Configuration.LastModified,
    State: Configuration.State
  }'
```

### 6. Site Health Check (if DOMAIN is set)

```bash
# Basic connectivity
curl -I https://${DOMAIN}

# Response timing
curl -w "Connect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
  -o /dev/null -s https://${DOMAIN}
```

## Status Summary Format

Display a summary table:

```
AWS Docusaurus Status
=====================

CloudFront Distribution: ${CLOUDFRONT_DISTRIBUTION_ID}
├── Status: Deployed
├── Domain: d1234567890.cloudfront.net
└── Enabled: true

S3 Bucket: ${S3_BUCKET}
├── Objects: 156
└── Size: 12.4 MB

Certificate:
├── Status: ISSUED
├── Domain: docs.example.com
└── Expires: 2025-12-20

Last Invalidations:
├── I1234... - Completed - 2024-12-20 10:30
└── I5678... - Completed - 2024-12-19 15:45

Site Health: https://${DOMAIN}
├── Status: 200 OK
├── TTFB: 0.123s
└── Cache-Control: OK
```

## Troubleshooting Guide

| Symptom | Check | Solution |
|---------|-------|----------|
| 403 Forbidden | S3 bucket policy | Verify OAI configuration |
| 502 Bad Gateway | Lambda@Edge logs | Check us-east-1 CloudWatch |
| Stale content | Invalidation status | Create new invalidation |
| Slow response | Cache hit rate | Verify cache headers |
| Certificate error | ACM status | Check renewal/validation |

## Quick Actions

After status check, offer these actions:

1. **Invalidate cache** - Create new CloudFront invalidation
2. **View logs** - Open CloudWatch logs (if Lambda@Edge)
3. **Redeploy** - Run `/aws-docusaurus:deploy`

## CI/CD Examples

### GitHub Actions

```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install & Build
        run: |
          npm ci
          npm run build

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-3

      - name: Deploy to S3
        run: aws s3 sync build/ s3://${{ secrets.S3_BUCKET }}/ --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
```

### GitLab CI

```yaml
deploy:
  stage: deploy
  image: node:20
  before_script:
    - apt-get update && apt-get install -y awscli
  script:
    - npm ci
    - npm run build
    - aws s3 sync build/ s3://${S3_BUCKET}/ --delete
    - aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} --paths "/*"
  only:
    - main
```
