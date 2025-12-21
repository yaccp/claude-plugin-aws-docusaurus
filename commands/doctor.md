---
description: Diagnose issues with plugin configuration and AWS setup
---

# AWS Docusaurus: Doctor

Diagnose issues with the plugin configuration and AWS setup.

## Diagnostic Steps

### Step 1: Check Prerequisites

Run the following checks and display results:

```
AWS Docusaurus Doctor
=====================

Checking prerequisites...

CLI Tools:
├── aws CLI:      ✓ v2.15.0
├── gh CLI:       ✓ v2.40.0
├── node:         ✓ v20.10.0
└── npm:          ✓ v10.2.3

AWS Configuration:
├── Profile:      default
├── Region:       eu-west-3
├── Credentials:  ✓ Valid
└── Identity:     arn:aws:iam::123456789012:user/deploy
```

**Check commands:**
```bash
# CLI versions
aws --version
gh --version
node --version
npm --version

# AWS identity
aws sts get-caller-identity --profile ${AWS_PROFILE:-default}
```

### Step 2: Check Plugin Configuration

Read configuration from `.claude/yaccp/aws-docusaurus/config.json`:

```
Plugin Configuration:
├── Config file:  ✓ Found
├── S3 Bucket:    my-docs
├── CloudFront:   E1234567890ABC
├── Domain:       docs.example.com
└── Hosted Zone:  Z1234567890ABC
```

If config file not found:
```
Plugin Configuration:
└── Config file:  ✗ Not found

Suggestion: Run /yaccp-aws-docusaurus:infra to create infrastructure
```

### Step 3: Check AWS Resources

If configuration exists, verify AWS resources:

```
AWS Resources:
├── S3 Bucket:
│   ├── Exists:   ✓
│   ├── Region:   eu-west-3
│   └── Objects:  142
│
├── CloudFront:
│   ├── Exists:   ✓
│   ├── Status:   Deployed
│   ├── Enabled:  true
│   └── Domain:   d123456.cloudfront.net
│
├── ACM Certificate:
│   ├── Exists:   ✓
│   ├── Status:   ISSUED
│   └── Domain:   docs.example.com
│
└── Route53 Record:
    ├── Exists:   ✓
    ├── Type:     A (Alias)
    └── Target:   d123456.cloudfront.net
```

**Check commands:**
```bash
# S3
aws s3api head-bucket --bucket ${S3_BUCKET}
aws s3 ls s3://${S3_BUCKET} --summarize

# CloudFront
aws cloudfront get-distribution --id ${CLOUDFRONT_DISTRIBUTION_ID}

# ACM (us-east-1)
aws acm list-certificates --region us-east-1

# Route53
aws route53 list-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID}
```

### Step 4: Check IAM Permissions

Test required permissions:

```
IAM Permissions:
├── s3:PutObject:           ✓
├── s3:DeleteObject:        ✓
├── s3:ListBucket:          ✓
├── cloudfront:CreateInvalidation: ✓
├── cloudfront:GetDistribution:    ✓
├── acm:RequestCertificate: ✓
├── route53:ChangeResourceRecordSets: ✓
└── lambda:CreateFunction:  ✓ (optional)
```

### Step 5: Common Issues Detection

Detect and suggest fixes for common issues:

```
Issues Detected:
================

⚠️  AWS credentials expire in 2 hours
    Suggestion: Refresh credentials with `aws sso login`

⚠️  CloudFront distribution is "InProgress"
    Suggestion: Wait 15-30 minutes for deployment to complete

✗  S3 bucket not accessible
    Error: AccessDenied
    Suggestion: Check bucket policy and IAM permissions

✗  Certificate pending validation
    Suggestion: Add CNAME record to Route53 or wait for DNS propagation
```

### Step 6: Display Summary

```
Diagnostic Summary
==================

Status: 2 issues found

Prerequisites:     ✓ All OK
Configuration:     ✓ Found
AWS Resources:     ⚠️ 1 warning
IAM Permissions:   ✓ All OK
Common Issues:     ✗ 1 error
```

### Step 7: Offer Next Steps

Use AskUserQuestion:
"What would you like to do next?"
- "View detailed error logs"
- "Create a GitHub issue"
- "Run /yaccp-aws-docusaurus:status"
- "Nothing, I'll fix it myself"

#### If "View detailed error logs":
Display full error output from failed checks.

#### If "Create a GitHub issue":
```
I'll help you create an issue with the diagnostic information.

The following will be included:
• CLI versions
• AWS region and profile
• Error messages
• Resource status

Note: Sensitive information (account IDs, ARNs) will be redacted.
```

Then run `/yaccp-aws-docusaurus:issues` with pre-filled information.

## Diagnostic Checks Reference

| Check | Command | Success Criteria |
|-------|---------|------------------|
| AWS CLI | `aws --version` | Returns version |
| AWS Credentials | `aws sts get-caller-identity` | Returns identity |
| S3 Access | `aws s3api head-bucket` | No error |
| CloudFront Status | `aws cloudfront get-distribution` | Status = "Deployed" |
| Certificate Status | `aws acm describe-certificate` | Status = "ISSUED" |
| DNS Resolution | `dig +short ${DOMAIN}` | Returns CloudFront domain |
| HTTPS Access | `curl -I https://${DOMAIN}` | Status 200 |

## Error Messages Reference

| Error | Cause | Solution |
|-------|-------|----------|
| `ExpiredToken` | AWS session expired | Run `aws sso login` or refresh credentials |
| `AccessDenied` on S3 | Missing permissions | Check IAM policy |
| `NoSuchBucket` | Bucket doesn't exist | Run `/yaccp-aws-docusaurus:infra` |
| `NoSuchDistribution` | CloudFront not found | Run `/yaccp-aws-docusaurus:infra` |
| `InvalidChangeBatch` | DNS record conflict | Check existing Route53 records |
| `LimitExceeded` | AWS quota reached | Request limit increase |

## Output Format

Use visual indicators:
- `✓` - Check passed
- `⚠️` - Warning (non-blocking)
- `✗` - Error (blocking)

Use tree structure for hierarchy:
```
Parent:
├── Child 1:  value
├── Child 2:  value
└── Child 3:  value
```
