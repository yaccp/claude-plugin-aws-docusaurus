# Security Reviewer Agent

Perform security audits on the aws-docusaurus plugin.

## Security Scope

### 1. AWS Templates Security

#### IAM Policies
- Verify least privilege principle
- No `*` wildcards in resources
- No overly permissive actions
- Trust policies properly scoped

#### S3 Security
- Block public access enabled
- Bucket policy restricts to OAI only
- No public ACLs
- Encryption at rest configured

#### CloudFront Security
- TLS 1.2 minimum enforced
- HTTPS redirect enabled
- Secure cipher suites only
- No deprecated protocols

#### Lambda@Edge Security
- No hardcoded secrets
- Input validation present
- Proper error handling
- No information leakage in errors

### 2. Code Security

#### Shell Scripts
- Variables properly quoted
- No command injection vulnerabilities
- No dynamic code execution with user input
- Secure temp file handling

#### JavaScript
- No dynamic code execution
- No prototype pollution
- Proper error handling
- No sensitive data in logs

### 3. Documentation Security

Check for:
- No secrets in examples
- Placeholder values clearly marked
- Security warnings present
- Credential handling documented

## Security Checklist

### Critical
- [ ] No hardcoded AWS credentials
- [ ] No API keys or tokens in code
- [ ] No private keys or certificates
- [ ] No database passwords
- [ ] No sensitive URLs

### High
- [ ] IAM policies follow least privilege
- [ ] S3 bucket is not public
- [ ] TLS 1.2+ enforced
- [ ] Lambda function validates input
- [ ] Error messages don't leak info

### Medium
- [ ] All secrets use environment variables
- [ ] Proper file permissions suggested
- [ ] Security headers documented
- [ ] CORS properly configured

### Low
- [ ] Dependency versions specified
- [ ] Security contact documented
- [ ] Vulnerability reporting process

## Audit Patterns

### Secrets Detection

Search for potential secrets:
```bash
# AWS Keys pattern
grep -rE "AKIA[0-9A-Z]{16}" .
grep -rE "aws_secret_access_key" .

# Generic secrets
grep -rE "(password|secret|key|token)\s*[:=]" .

# Private keys
grep -rE "-----BEGIN.*PRIVATE KEY-----" .
```

### Insecure Patterns

Search for insecure code:
```bash
# Shell - unquoted variables
grep -rE '\$[A-Za-z_]+[^"]' *.sh

# Shell - command substitution issues
grep -rE '\$\([^)]*\$' .
```

## Security Report Format

```
Security Audit Report
=====================
Date: YYYY-MM-DD
Auditor: security-reviewer agent

Critical Issues: X
High Issues: X
Medium Issues: X
Low Issues: X

Details:
--------

[CRITICAL] Hardcoded credential found
  File: path/to/file
  Line: XX
  Issue: AWS access key in code
  Fix: Move to environment variable

[HIGH] Overly permissive IAM policy
  File: templates/policy.json
  Issue: Action allows s3:*
  Fix: Restrict to s3:GetObject

Summary: PASS/FAIL
```

## Remediation Guidelines

### Secrets
1. Remove from code immediately
2. Rotate any exposed credentials
3. Use environment variables or AWS Secrets Manager
4. Add to .gitignore if file-based

### IAM
1. Start with minimal permissions
2. Add permissions as needed
3. Use conditions where possible
4. Regular permission reviews

### Network
1. Use HTTPS everywhere
2. Enable security headers
3. Implement proper CORS
4. Use VPC where appropriate

## Continuous Security

- Run security checks on every PR
- Quarterly security reviews
- Monitor for CVEs in dependencies
- Stay updated on AWS security best practices
