---
description: Check AWS infrastructure status and health
---

# AWS Docusaurus: Check Status

Check AWS infrastructure and deployment status for the selected environment.

## Configuration Storage

Read configuration from `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "environments": {
    "dev": {
      "AWS_PROFILE": "company-dev",
      "AWS_REGION": "eu-west-1",
      "S3_BUCKET": "mysite-dev",
      "CLOUDFRONT_DISTRIBUTION_ID": "E1DEV...",
      "DOMAIN": "dev.example.com"
    },
    "staging": { ... },
    "prod": { ... }
  },
  "currentEnvironment": "dev"
}
```

## Interactive Flow

### Step 0: Resolve Environment

1. Check `$PLUGIN_ENV` for environment override
2. Load config and get `currentEnvironment`
3. If no current environment set, use AskUserQuestion:
   "Which environment do you want to check?"
   - "dev" (Development)
   - "staging" (Staging)
   - "prod" (Production)
   - "all" (Check all environments)

4. Load variables from `environments[selectedEnv]`
5. Display: "Checking status for: ${ENV_NAME}"

### Step 1: Load Saved Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

### Step 2: Check and Prompt for Variables

For each variable, check in this order:
1. Environment variable
2. Saved config (`infra` and `deploy` sections)
3. If not found, use AskUserQuestion

**Required:**
- **CLOUDFRONT_DISTRIBUTION_ID**: CloudFront ID
- **S3_BUCKET**: S3 bucket name

**Optional:**
- **AWS_PROFILE**: Default "default"
- **DOMAIN**: For health checks

### Step 3: Display Summary and Confirm

```
Status Check Configuration
==========================
CloudFront ID:   ${CLOUDFRONT_DISTRIBUTION_ID}
S3 Bucket:       ${S3_BUCKET}
AWS Profile:     ${AWS_PROFILE}
Domain:          ${DOMAIN}

Run status checks?
```

Use AskUserQuestion:
- "Yes, check status"
- "No, cancel"

### Step 4: Save Configuration (if new values provided)

If user provided new values, update `.claude/yaccp/aws-docusaurus/config.json`.

### Step 5: Execute Status Checks

#### CloudFront Status
```bash
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query '{Status: Distribution.Status, Enabled: Distribution.DistributionConfig.Enabled}'
```

#### S3 Bucket Status
```bash
aws s3api head-bucket --bucket ${S3_BUCKET}
aws s3 ls s3://${S3_BUCKET}/ --recursive --summarize | tail -2
```

#### Recent Invalidations
```bash
aws cloudfront list-invalidations \
  --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'InvalidationList.Items[0:3]'
```

#### Certificate Status
```bash
CERT_ARN=$(aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'Distribution.DistributionConfig.ViewerCertificate.ACMCertificateArn' \
  --output text)

aws acm describe-certificate \
  --region us-east-1 \
  --certificate-arn ${CERT_ARN} \
  --query '{Status: Certificate.Status, Expiry: Certificate.NotAfter}'
```

#### Site Health (if DOMAIN set)
```bash
curl -sI https://${DOMAIN} | head -1
curl -w "TTFB: %{time_starttransfer}s\n" -o /dev/null -s https://${DOMAIN}
```

### Step 6: Display Results

```
AWS Docusaurus Status
=====================

CloudFront: ${CLOUDFRONT_DISTRIBUTION_ID}
├── Status:  Deployed
├── Enabled: true
└── Domain:  ${CF_DOMAIN}

S3 Bucket: ${S3_BUCKET}
├── Status:  Accessible
├── Objects: ${OBJECT_COUNT}
└── Size:    ${BUCKET_SIZE}

Certificate:
├── Status:  ISSUED
└── Expires: ${CERT_EXPIRY}

Site Health: https://${DOMAIN}
├── Status:  200 OK
└── TTFB:    ${TTFB}s

Last Invalidations:
├── ${INV_1_ID} - ${INV_1_STATUS}
└── ${INV_2_ID} - ${INV_2_STATUS}
```

### Step 7: Offer Quick Actions

Use AskUserQuestion:
"What would you like to do next?"
- "Invalidate CloudFront cache"
- "Redeploy site (/yaccp-aws-docusaurus:deploy)"
- "Nothing, done"
