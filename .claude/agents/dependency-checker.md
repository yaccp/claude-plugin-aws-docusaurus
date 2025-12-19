# Dependency Checker Agent

Monitor and validate external dependencies for the aws-docusaurus plugin.

## Dependencies to Monitor

### AWS Services
| Service | Version/API | Status |
|---------|-------------|--------|
| S3 | 2006-03-01 | Stable |
| CloudFront | 2020-05-31 | Stable |
| ACM | 2015-12-08 | Stable |
| Route53 | 2013-04-01 | Stable |
| Lambda | 2015-03-31 | Stable |
| IAM | 2010-05-08 | Stable |

### AWS CLI
- Minimum version: 2.x
- Required commands: s3, cloudfront, acm, route53, lambda, iam

### Node.js (for Docusaurus)
- Minimum version: 20.x
- Required for: Docusaurus build

### Docusaurus
- Recommended version: 3.x
- Classic preset assumed

## Compatibility Checks

### AWS API Compatibility

Check if templates use current API versions:

```bash
# Verify CloudFront config fields
aws cloudfront create-distribution --generate-cli-skeleton | jq 'keys'

# Verify S3 policy structure
aws s3api get-bucket-policy --generate-cli-skeleton
```

### CLI Compatibility

Verify AWS CLI commands used in templates:
```bash
# Check if commands exist
aws s3 sync --help > /dev/null 2>&1
aws cloudfront create-invalidation --help > /dev/null 2>&1
```

## Deprecation Monitoring

### Watch For

1. **AWS Service Changes**
   - Deprecated API versions
   - Removed features
   - Changed default behaviors

2. **CloudFront Updates**
   - New TLS versions
   - Deprecated cipher suites
   - Changed cache behaviors

3. **Lambda@Edge Changes**
   - Runtime deprecations (Node.js versions)
   - API changes
   - Size limits

## Update Procedures

### When Dependency Updates

1. **Test in sandbox**
   - Create test infrastructure
   - Deploy with new version
   - Verify functionality

2. **Update templates**
   - Modify affected templates
   - Update version comments
   - Test again

3. **Document changes**
   - Add to CHANGELOG
   - Update README if needed
   - Note any breaking changes

4. **Release**
   - Bump version appropriately
   - Create release notes
   - Tag and publish

## Dependency Report Format

```
Dependency Check Report
=======================
Date: YYYY-MM-DD

AWS Services:
  [OK] S3 - API current
  [OK] CloudFront - API current
  [WARN] Lambda - Node.js 18 EOL approaching
  [OK] Route53 - API current

CLI Tools:
  [OK] aws-cli 2.15.0 (minimum 2.0)
  [OK] jq 1.7 available

Frameworks:
  [OK] Docusaurus 3.x supported
  [OK] Node.js 20.x supported

Upcoming Changes:
  - Lambda Node.js 18 EOL: 2025-04-30
  - Consider updating to Node.js 20

Recommendations:
  1. Update Lambda runtime to nodejs20.x
  2. No other changes needed

Status: OK (1 warning)
```

## Automation

### Weekly Check
```yaml
# .github/workflows/dependency-check.yml
name: Dependency Check
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check AWS API versions
        run: |
          # Check for deprecated APIs
          echo "Checking AWS compatibility..."
      - name: Check Node.js version
        run: |
          node --version
```

### Notifications

When issues found:
- Create GitHub issue
- Tag as `dependency`
- Assign to maintainers
