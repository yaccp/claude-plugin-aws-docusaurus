---
description: Create complete AWS infrastructure (S3, CloudFront, ACM, Route53)
---

# AWS Docusaurus: Create AWS Infrastructure

Create complete AWS infrastructure for static site hosting in the selected environment.

## Configuration Storage

Store and retrieve configuration from `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "environments": {
    "dev": {
      "AWS_PROFILE": "company-dev",
      "AWS_REGION": "eu-west-1",
      "AWS_ACCOUNT_ID": "111111111111",
      "SITE_NAME": "mysite-dev",
      "DOMAIN": "dev.example.com",
      "HOSTED_ZONE_ID": "Z1DEV...",
      "S3_BUCKET": "mysite-dev",
      "CLOUDFRONT_DISTRIBUTION_ID": "E1DEV...",
      "AUTH_ENABLED": false
    },
    "staging": { ... },
    "prod": { ... }
  },
  "currentEnvironment": "dev",
  "defaults": {
    "AWS_REGION": "eu-west-1"
  }
}
```

## Interactive Flow

### Step 0: Resolve Environment

1. Check `$PLUGIN_ENV` for environment override
2. Load config and get `currentEnvironment`
3. If no current environment set, use AskUserQuestion:
   "Which environment do you want to create infrastructure for?"
   - "dev" (Development)
   - "staging" (Staging)
   - "prod" (Production)
   - "new" (Create new environment)

4. If "new", prompt for environment name
5. Load variables from `environments[selectedEnv]` (if exists)
6. Display: "Creating infrastructure for: ${ENV_NAME}"

### Step 1: Load Saved Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

### Step 2: Check and Prompt for Variables

For each variable, check in this order:
1. Environment variable (`echo $VAR`)
2. Saved config (`.claude/yaccp/aws-docusaurus/config.json` → infra section)
3. If not found, use AskUserQuestion to prompt

**Required:**
- **SITE_NAME**: S3 bucket name (e.g., "my-docs")
- **DOMAIN**: Custom domain (e.g., "docs.example.com")
- **HOSTED_ZONE_ID**: Route53 zone ID (e.g., "Z1234567890ABC")
  - Hint: `aws route53 list-hosted-zones`

**Optional (with defaults):**
- **AWS_PROFILE**: Default "default"
- **AWS_REGION**: Default "eu-west-3"

### Step 3: Basic Authentication

Use AskUserQuestion:
"Do you want to enable Basic Authentication?"
- "Yes"
- "No"

If yes, prompt for:
- **AUTH_USERNAME**: Username
- **AUTH_PASSWORD**: Password (min 8 chars) - DO NOT save password in config

### Step 4: Display Summary and Confirm

```
Infrastructure Configuration
============================
Site Name:       ${SITE_NAME}
Domain:          ${DOMAIN}
Hosted Zone ID:  ${HOSTED_ZONE_ID}
AWS Profile:     ${AWS_PROFILE}
AWS Region:      ${AWS_REGION}
Basic Auth:      ${AUTH_ENABLED}

Resources to create:
• S3 Bucket: ${SITE_NAME}
• ACM Certificate: ${DOMAIN}
• CloudFront Distribution
• Route53 A Record
• Lambda@Edge (if auth enabled)

Proceed?
```

Use AskUserQuestion:
- "Yes, create infrastructure"
- "No, let me change something"

### Step 5: Save Configuration

After confirmation, save to `.claude/yaccp/aws-docusaurus/config.json`:

```bash
mkdir -p .claude/yaccp/aws-docusaurus
```

Write/update config.json with infra section (exclude AUTH_PASSWORD for security).

### Step 6: Execute Infrastructure Creation

1. Create S3 bucket (private)
2. Request ACM certificate in us-east-1
3. Wait for certificate validation
4. Create CloudFront OAI
5. Configure S3 bucket policy
6. Create Lambda@Edge (if auth)
7. Create CloudFront distribution
8. Create Route53 alias

### Step 7: Save Results and Show Summary

Update config.json with created resources:
```json
{
  "infra": {
    "...": "...",
    "S3_BUCKET": "${SITE_NAME}",
    "CLOUDFRONT_DISTRIBUTION_ID": "${CF_ID}"
  }
}
```

Display:
```
Infrastructure created!
Configuration saved to .claude/yaccp/aws-docusaurus/config.json

S3 Bucket:       ${SITE_NAME}
CloudFront ID:   ${CF_ID}
Site URL:        https://${DOMAIN}

Next step: /yaccp-aws-docusaurus:deploy
```

## Architecture

```
Route53 → CloudFront (+ Lambda@Edge) → S3 (private)
              ↓
         ACM Certificate
```
