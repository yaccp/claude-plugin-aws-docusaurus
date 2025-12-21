---
description: Destroy all AWS infrastructure created by infra command
---

# AWS Docusaurus: Destroy Infrastructure

Destroy all AWS infrastructure created by `/yaccp-aws-docusaurus:infra` for the selected environment.

## Configuration Storage

Read configuration from `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "environments": {
    "dev": {
      "AWS_PROFILE": "company-dev",
      "AWS_REGION": "eu-west-1",
      "SITE_NAME": "mysite-dev",
      "DOMAIN": "dev.example.com",
      "S3_BUCKET": "mysite-dev",
      "CLOUDFRONT_DISTRIBUTION_ID": "E1DEV...",
      "HOSTED_ZONE_ID": "Z1DEV...",
      "AUTH_ENABLED": false
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
3. Use AskUserQuestion:
   "Which environment do you want to DESTROY?"
   - "dev" (Development)
   - "staging" (Staging)
   - "prod" (Production) - Shows extra warning

4. If "prod" selected, show additional warning:
   ```
   ⚠️  WARNING: You are about to destroy PRODUCTION infrastructure!
   This action is irreversible and will cause downtime.
   ```

5. Load variables from `environments[selectedEnv]`
6. Display: "Preparing to destroy: ${ENV_NAME} (${AWS_ACCOUNT_ID})"

### Step 1: Load Saved Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

If no configuration exists, inform the user:
```
No infrastructure configuration found at .claude/yaccp/aws-docusaurus/config.json

Run /yaccp-aws-docusaurus:infra first to create infrastructure, or provide
the resource IDs manually.
```

### Step 2: Check and Prompt for Variables

For each variable, check in this order:
1. Saved config (`.claude/yaccp/aws-docusaurus/config.json` → infra section)
2. Environment variable
3. If not found, use AskUserQuestion to prompt

**Required:**
- **CLOUDFRONT_DISTRIBUTION_ID**: CloudFront distribution ID
- **S3_BUCKET**: S3 bucket name
- **DOMAIN**: Custom domain for Route53 cleanup
- **HOSTED_ZONE_ID**: Route53 zone ID

**Optional (with defaults):**
- **AWS_PROFILE**: Default "default"
- **AWS_REGION**: Default "eu-west-3"

### Step 3: Discover Resources to Delete

Query AWS to find all associated resources:

```bash
# Get CloudFront distribution details
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --profile ${AWS_PROFILE}

# Get Lambda@Edge function ARN (if any)
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'Distribution.DistributionConfig.DefaultCacheBehavior.LambdaFunctionAssociations.Items[*].LambdaFunctionARN' \
  --profile ${AWS_PROFILE}

# Get ACM certificate ARN
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'Distribution.DistributionConfig.ViewerCertificate.ACMCertificateArn' \
  --output text \
  --profile ${AWS_PROFILE}

# Get Origin Access Identity
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'Distribution.DistributionConfig.Origins.Items[0].S3OriginConfig.OriginAccessIdentity' \
  --output text \
  --profile ${AWS_PROFILE}

# Find Route53 record
aws route53 list-resource-record-sets \
  --hosted-zone-id ${HOSTED_ZONE_ID} \
  --query "ResourceRecordSets[?Name=='${DOMAIN}.']" \
  --profile ${AWS_PROFILE}
```

### Step 4: Display Summary and Confirm

```
⚠️  INFRASTRUCTURE DESTRUCTION
==============================

This will PERMANENTLY DELETE the following resources:

CloudFront Distribution:
└── ID: ${CLOUDFRONT_DISTRIBUTION_ID}

S3 Bucket:
├── Name: ${S3_BUCKET}
└── All objects will be deleted!

Route53 Record:
├── Zone: ${HOSTED_ZONE_ID}
└── Record: ${DOMAIN}

ACM Certificate:
└── ARN: ${CERT_ARN}

Origin Access Identity:
└── ID: ${OAI_ID}

Lambda@Edge (if enabled):
└── Function: ${LAMBDA_ARN}

⚠️  THIS ACTION CANNOT BE UNDONE!
```

Use AskUserQuestion:
"Are you sure you want to destroy all infrastructure?"
- "Yes, destroy everything"
- "No, cancel"

If user confirms, ask for final confirmation:
"Type 'destroy' to confirm deletion of all resources:"
- Use a text input or require explicit confirmation

### Step 5: Execute Destruction (Ordered)

Resources must be deleted in this specific order due to dependencies:

#### 5.1: Delete Route53 Alias Record
```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id ${HOSTED_ZONE_ID} \
  --change-batch '{
    "Changes": [{
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "${DOMAIN}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "${CF_DOMAIN_NAME}",
          "EvaluateTargetHealth": false
        }
      }
    }]
  }' \
  --profile ${AWS_PROFILE}
```

#### 5.2: Disable CloudFront Distribution
```bash
# Get current ETag
ETAG=$(aws cloudfront get-distribution-config \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'ETag' \
  --output text \
  --profile ${AWS_PROFILE})

# Get config and disable
aws cloudfront get-distribution-config \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --profile ${AWS_PROFILE} > /tmp/cf-config.json

# Modify Enabled to false and update
jq '.DistributionConfig.Enabled = false' /tmp/cf-config.json > /tmp/cf-config-disabled.json

aws cloudfront update-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --if-match ${ETAG} \
  --distribution-config file:///tmp/cf-config-disabled.json \
  --profile ${AWS_PROFILE}
```

#### 5.3: Wait for CloudFront to be Disabled
```bash
aws cloudfront wait distribution-deployed \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --profile ${AWS_PROFILE}
```

This may take 10-15 minutes. Inform the user:
```
Waiting for CloudFront distribution to be disabled...
This may take 10-15 minutes.
```

#### 5.4: Delete CloudFront Distribution
```bash
ETAG=$(aws cloudfront get-distribution-config \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'ETag' \
  --output text \
  --profile ${AWS_PROFILE})

aws cloudfront delete-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --if-match ${ETAG} \
  --profile ${AWS_PROFILE}
```

#### 5.5: Delete CloudFront Origin Access Identity
```bash
ETAG=$(aws cloudfront get-cloud-front-origin-access-identity \
  --id ${OAI_ID} \
  --query 'ETag' \
  --output text \
  --profile ${AWS_PROFILE})

aws cloudfront delete-cloud-front-origin-access-identity \
  --id ${OAI_ID} \
  --if-match ${ETAG} \
  --profile ${AWS_PROFILE}
```

#### 5.6: Empty and Delete S3 Bucket
```bash
# Delete all objects (including versions if versioning enabled)
aws s3 rm s3://${S3_BUCKET} --recursive --profile ${AWS_PROFILE}

# Delete bucket
aws s3 rb s3://${S3_BUCKET} --profile ${AWS_PROFILE}
```

#### 5.7: Delete Lambda@Edge Function (if exists)

Note: Lambda@Edge functions must be deleted from us-east-1 and require
all CloudFront associations to be removed first.

```bash
# Wait for replicas to be deleted (can take hours)
# Lambda@Edge replicas are automatically deleted after CloudFront disassociation
# but it may take up to several hours

aws lambda delete-function \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --region us-east-1 \
  --profile ${AWS_PROFILE}
```

If Lambda deletion fails due to replicas, inform the user:
```
Lambda@Edge function cannot be deleted yet.
Replicas are still being removed by AWS (can take several hours).
You can delete it manually later:
  aws lambda delete-function --function-name ${LAMBDA_FUNCTION_NAME} --region us-east-1
```

#### 5.8: Delete ACM Certificate
```bash
aws acm delete-certificate \
  --certificate-arn ${CERT_ARN} \
  --region us-east-1 \
  --profile ${AWS_PROFILE}
```

### Step 6: Clean Up Configuration

Remove or update `.claude/yaccp/aws-docusaurus/config.json`:

Option A: Remove the infra section entirely
Option B: Mark as destroyed

```json
{
  "infra": {
    "destroyed": true,
    "destroyed_at": "2024-01-15T10:30:00Z"
  }
}
```

### Step 7: Display Results

```
Infrastructure Destroyed
========================

✓ Route53 Record:     ${DOMAIN} deleted
✓ CloudFront:         ${CLOUDFRONT_DISTRIBUTION_ID} deleted
✓ Origin Access ID:   ${OAI_ID} deleted
✓ S3 Bucket:          ${S3_BUCKET} deleted
✓ ACM Certificate:    deleted
△ Lambda@Edge:        pending deletion (replicas still removing)

Configuration cleaned from .claude/yaccp/aws-docusaurus/config.json

To recreate infrastructure: /yaccp-aws-docusaurus:infra
```

## Error Handling

### Common Errors

1. **Distribution not disabled**: Wait and retry
2. **Bucket not empty**: Run `aws s3 rm --recursive` first
3. **Lambda has replicas**: Wait or delete later
4. **Certificate in use**: Ensure CloudFront is deleted first
5. **Access denied**: Check AWS credentials and permissions

### Partial Cleanup

If destruction fails midway, display what was deleted and what remains:
```
Partial Destruction - Some resources remain
===========================================
✓ Deleted: Route53 Record
✓ Deleted: CloudFront Distribution
✗ Failed:  S3 Bucket (not empty)
✗ Skipped: ACM Certificate

Manual cleanup required for remaining resources.
```

## Safety Features

- Double confirmation required
- Resources discovered dynamically (won't delete wrong resources)
- Ordered deletion respects AWS dependencies
- Clear indication of what will be deleted before execution
- Graceful handling of already-deleted resources
