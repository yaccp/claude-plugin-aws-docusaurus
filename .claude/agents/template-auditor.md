# Template Auditor Agent

Audit and validate all AWS templates in the plugin.

## Templates to Audit

```
templates/
├── cloudfront-config.template.json
├── s3-bucket-policy.template.json
├── route53-alias.template.json
├── deploy.template.sh
└── lambda/
    ├── basic-auth.template.js
    └── trust-policy.json
```

## Validation Rules

### JSON Templates

#### cloudfront-config.template.json
- [ ] Valid JSON syntax
- [ ] All required CloudFront fields present
- [ ] Placeholders: `{{DOMAIN}}`, `{{S3_BUCKET}}`, `{{ACM_CERTIFICATE_ARN}}`, `{{OAI_ID}}`
- [ ] TLS version is 1.2 or higher
- [ ] Price class is valid
- [ ] Default root object set

#### s3-bucket-policy.template.json
- [ ] Valid JSON syntax
- [ ] Policy version is "2012-10-17"
- [ ] Principal uses OAI format
- [ ] Actions are minimal (s3:GetObject)
- [ ] Resource includes bucket ARN
- [ ] Placeholders: `{{BUCKET_NAME}}`, `{{OAI_CANONICAL_USER_ID}}`

#### route53-alias.template.json
- [ ] Valid JSON syntax
- [ ] Type is "A" or "AAAA"
- [ ] AliasTarget uses CloudFront hosted zone ID
- [ ] Placeholders: `{{DOMAIN}}`, `{{CLOUDFRONT_DOMAIN}}`, `{{HOSTED_ZONE_ID}}`

#### trust-policy.json
- [ ] Valid JSON syntax
- [ ] Service is correct for Lambda@Edge
- [ ] Action is sts:AssumeRole
- [ ] No wildcards in principal

### Shell Templates

#### deploy.template.sh
- [ ] Valid bash syntax (`bash -n`)
- [ ] Shebang present (`#!/bin/bash`)
- [ ] Error handling (`set -e` or explicit checks)
- [ ] All variables quoted
- [ ] No hardcoded paths
- [ ] Placeholders documented
- [ ] AWS CLI commands are valid

### JavaScript Templates

#### basic-auth.template.js
- [ ] Valid JavaScript syntax
- [ ] exports.handler defined
- [ ] Proper async handling
- [ ] Error responses correct (401, 403)
- [ ] Headers properly set
- [ ] No hardcoded credentials (placeholders only)
- [ ] CloudFront Lambda@Edge compatible

## Security Checks

### IAM Policies
- No `*` in resources (except where required)
- Least privilege principle
- No inline credentials

### S3 Policies
- Block public access configured
- OAI-only access
- No s3:* actions

### Lambda
- No secrets in code
- Credentials via placeholders only
- Proper input validation

## Placeholder Inventory

| Placeholder | Template | Description |
|-------------|----------|-------------|
| `{{BUCKET_NAME}}` | s3-bucket-policy | S3 bucket name |
| `{{OAI_CANONICAL_USER_ID}}` | s3-bucket-policy | OAI canonical user |
| `{{DOMAIN}}` | cloudfront, route53 | Site domain |
| `{{S3_BUCKET}}` | cloudfront | Origin bucket |
| `{{ACM_CERTIFICATE_ARN}}` | cloudfront | SSL cert ARN |
| `{{OAI_ID}}` | cloudfront | Origin Access Identity |
| `{{CLOUDFRONT_DOMAIN}}` | route53 | Distribution domain |
| `{{HOSTED_ZONE_ID}}` | route53 | Route53 zone ID |
| `{{AUTH_USERNAME}}` | basic-auth | Basic auth user |
| `{{AUTH_PASSWORD}}` | basic-auth | Basic auth pass |

## Audit Report Format

```
Template Audit Report
=====================

cloudfront-config.template.json
  [PASS] Valid JSON
  [PASS] Required fields present
  [PASS] TLS 1.2+ configured
  [WARN] Consider adding custom error responses

s3-bucket-policy.template.json
  [PASS] Valid JSON
  [PASS] Policy follows least privilege
  [PASS] OAI-only access

Summary: 6 PASS, 1 WARN, 0 FAIL
```

## Maintenance Tasks

1. **Quarterly Review**: Verify templates match current AWS best practices
2. **AWS Updates**: Check for deprecated features or new requirements
3. **Security Patches**: Update if vulnerabilities found in patterns
