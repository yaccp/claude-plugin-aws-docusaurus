# AWS Docusaurus: Check Status

Check the status of your AWS infrastructure and recent deployments.

## Required Environment Variables

```bash
export CLOUDFRONT_DISTRIBUTION_ID="E1234567890ABC"
export S3_BUCKET="my-site"
export AWS_PROFILE="default"
export AWS_REGION="eu-west-3"
```

## Status Checks

### CloudFront Distribution Status

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

Expected output for healthy distribution:
```json
{
  "Status": "Deployed",
  "DomainName": "d1234567890.cloudfront.net",
  "Enabled": true,
  "PriceClass": "PriceClass_100",
  "HttpVersion": "http2"
}
```

### S3 Bucket Status

```bash
# Check bucket exists and is accessible
aws s3api head-bucket --bucket ${S3_BUCKET}

# Get bucket size and object count
aws s3 ls s3://${S3_BUCKET}/ --recursive --summarize | tail -2

# List recent files
aws s3 ls s3://${S3_BUCKET}/ --recursive --human-readable | head -20
```

### Recent Invalidations

```bash
aws cloudfront list-invalidations \
  --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'InvalidationList.Items[0:5].[Id,Status,CreateTime]' \
  --output table
```

### Certificate Status

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

### Lambda@Edge Status (if using auth)

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

## Health Check Commands

### Test Site Availability

```bash
# Basic connectivity
curl -I https://${DOMAIN}

# With timing
curl -w "Connect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
  -o /dev/null -s https://${DOMAIN}

# With auth (if enabled)
curl -u ${AUTH_USERNAME}:${AUTH_PASSWORD} -I https://${DOMAIN}
```

### Check Cache Headers

```bash
# HTML should have no-cache
curl -sI https://${DOMAIN}/index.html | grep -i cache-control
# Expected: cache-control: public, max-age=0, must-revalidate

# Static assets should have long cache
curl -sI https://${DOMAIN}/assets/css/styles.*.css | grep -i cache-control
# Expected: cache-control: public, max-age=31536000, immutable
```

## CloudWatch Metrics

Monitor these metrics in CloudWatch:

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| `Requests` | Total requests | Anomaly detection |
| `BytesDownloaded` | Bandwidth | Budget threshold |
| `4xxErrorRate` | Client errors | > 5% |
| `5xxErrorRate` | Server errors | > 1% |
| `CacheHitRate` | Cache efficiency | < 80% |

### Quick Metrics Query

```bash
# Get request count (last hour)
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name Requests \
  --dimensions Name=DistributionId,Value=${CLOUDFRONT_DISTRIBUTION_ID} \
  --start-time $(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Sum
```

## Troubleshooting

| Symptom | Check | Solution |
|---------|-------|----------|
| 403 Forbidden | S3 bucket policy | Verify OAI configuration |
| 502 Bad Gateway | Lambda@Edge logs | Check us-east-1 CloudWatch |
| Stale content | Invalidation status | Create new invalidation |
| Slow response | Cache hit rate | Verify cache headers |
| Certificate error | ACM status | Check renewal/validation |

## Cost Estimation

```bash
# Get current month costs (requires Cost Explorer API access)
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter '{
    "Dimensions": {
      "Key": "SERVICE",
      "Values": ["Amazon CloudFront", "Amazon S3"]
    }
  }'
```

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
