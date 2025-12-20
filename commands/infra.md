# AWS Docusaurus: Create AWS Infrastructure

Creates complete AWS infrastructure for hosting static sites with CloudFront CDN, S3 storage, HTTPS, and optional Basic Authentication.

## Interactive Configuration

Before proceeding, check if required environment variables are set. If any are missing, ask the user for the values using AskUserQuestion.

### Required Variables Check

Check these environment variables and prompt for missing ones:

1. **SITE_NAME** - Resource naming, S3 bucket name (e.g., "my-site")
2. **DOMAIN** - Custom domain with subdomain (e.g., "docs.example.com")
3. **HOSTED_ZONE_ID** - Route53 hosted zone ID (e.g., "Z1234567890ABC")
4. **AWS_PROFILE** - AWS CLI profile name (default: "default")
5. **AWS_REGION** - Primary AWS region (default: "eu-west-3")

### Optional - Basic Authentication

Ask the user if they want to enable Basic Auth protection:

- **Enable Basic Auth?** - Yes/No question
- If yes, ask for:
  - **AUTH_USERNAME** - Username for Basic Auth
  - **AUTH_PASSWORD** - Password (min 8 chars, suggest strong password)

## Execution Flow

1. Check environment variables
2. Use AskUserQuestion for any missing required variables
3. Ask about Basic Auth option
4. Show summary and confirm before creating infrastructure
5. Execute infrastructure creation steps

## Architecture Created

```
┌─────────────────────────────────────────────────────────────────┐
│                          INTERNET                               │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │      Route53          │
                    │    DNS Alias          │
                    │  (${DOMAIN})          │
                    └───────────┬───────────┘
                                │
┌───────────────────────────────▼─────────────────────────────────┐
│                     CloudFront CDN                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Lambda@Edge (viewer-request) - Basic Auth (if enabled)    │ │
│  └────────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  ACM Certificate (HTTPS) - TLS 1.2+                        │ │
│  └────────────────────────────────────────────────────────────┘ │
│  • HTTPS redirect  • Gzip compression  • Edge caching          │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │     S3 Bucket         │
                    │   (Private - OAI)     │
                    │  ${SITE_NAME}         │
                    └───────────────────────┘
```

## Infrastructure Components

| Component | Purpose | Region |
|-----------|---------|--------|
| S3 Bucket | Static file storage | ${AWS_REGION} |
| CloudFront | CDN distribution | Global (Edge) |
| ACM Certificate | HTTPS/TLS | us-east-1 (required) |
| Route53 Record | DNS alias | Global |
| Lambda@Edge | Basic Auth (optional) | us-east-1 |
| IAM Role | Lambda execution | Global |
| OAI | S3 access control | Global |

## Execution Steps

### Step 1: Create S3 Bucket

- Create bucket with LocationConstraint
- Block ALL public access
- Configure for private access only

### Step 2: Request ACM Certificate

- Request certificate in us-east-1 (CloudFront requirement)
- Create DNS validation CNAME record
- Wait for validation (5-30 minutes)

### Step 3: Create Origin Access Identity

- Create OAI for CloudFront to S3 access
- Get S3 canonical user ID

### Step 4: Configure S3 Bucket Policy

- Allow only OAI access
- Deny all public access

### Step 5: Create IAM Role (if Basic Auth)

- Create Lambda@Edge execution role
- Attach basic execution policy
- Wait for IAM propagation

### Step 6: Create Lambda@Edge Function (if Basic Auth)

- Create Node.js 20 function
- Deploy to us-east-1
- Publish version for CloudFront

### Step 7: Create CloudFront Distribution

- Configure S3 origin with OAI
- Set HTTPS redirect
- Enable compression
- Configure cache behaviors
- Attach Lambda@Edge (if auth)
- Set custom error pages (SPA support)

### Step 8: Create Route53 Alias

- Create A record alias to CloudFront
- Use CloudFront hosted zone ID (Z2FDTNDATAQYW2)

## Output Variables

After successful execution, display and suggest exporting:

```bash
export S3_BUCKET="${SITE_NAME}"
export CLOUDFRONT_DISTRIBUTION_ID="${CF_ID}"
export SITE_URL="https://${DOMAIN}"
export LAMBDA_VERSION_ARN="${LAMBDA_VERSION_ARN}"  # if auth enabled
```

## Verification

```bash
# Check CloudFront status (wait for "Deployed")
aws cloudfront get-distribution --id ${CF_ID} --query 'Distribution.Status'

# Test site (after deployment)
curl -I https://${DOMAIN}

# Test with auth (if enabled)
curl -u ${AUTH_USERNAME}:${AUTH_PASSWORD} https://${DOMAIN}
```

## Security Features

- **S3**: Private bucket, no public access
- **HTTPS**: Forced redirect, TLS 1.2 minimum
- **OAI**: CloudFront-only S3 access
- **Lambda@Edge**: Optional authentication layer

## Next Steps

Run `/aws-docusaurus:deploy` to deploy your site content.
