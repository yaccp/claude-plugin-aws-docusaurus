# AWS Docusaurus - Claude Context

## Migration Notice (v1.1.5)

**Breaking Change:** This plugin was renamed from `aws-docusaurus` to `yaccp-aws-docusaurus`.

### For Users Upgrading from v1.1.0 or Earlier

1. Update `enabledPlugins` in `.claude/settings.local.json`:
   ```json
   "enabledPlugins": {
     "yaccp-aws-docusaurus@yaccp": true
   }
   ```

2. Use new command format:
   - `/yaccp-aws-docusaurus:init` (was `/aws-docusaurus init`)
   - `/yaccp-aws-docusaurus:infra` (was `/aws-docusaurus infra`)
   - `/yaccp-aws-docusaurus:deploy` (was `/aws-docusaurus deploy`)
   - `/yaccp-aws-docusaurus:status` (was `/aws-docusaurus status`)

See [CHANGELOG.md](CHANGELOG.md#from-110-to-115) for full migration guide.

---

## Plugin Overview

AWS Docusaurus automates static site deployment to AWS. It creates and manages:
- S3 bucket (private, OAI access only)
- CloudFront CDN distribution
- ACM SSL certificate (us-east-1)
- Route53 DNS alias records
- Lambda@Edge Basic Auth (optional)

## Commands

| Command | Purpose |
|---------|---------|
| `/yaccp-aws-docusaurus:init` | Create new Docusaurus project with AWS-ready config |
| `/yaccp-aws-docusaurus:infra` | Provision complete AWS infrastructure |
| `/yaccp-aws-docusaurus:deploy` | Build and deploy to S3 + invalidate CloudFront |
| `/yaccp-aws-docusaurus:status` | Check infrastructure health and status |
| `/yaccp-aws-docusaurus:destroy-infra` | Destroy all AWS infrastructure |

## Key Files

```
.claude-plugin/
├── plugin.json          # Plugin metadata (name, version)
└── marketplace.json     # Marketplace listing

commands/
├── init.md              # /yaccp-aws-docusaurus:init
├── infra.md             # /yaccp-aws-docusaurus:infra
├── deploy.md            # /yaccp-aws-docusaurus:deploy
├── status.md            # /yaccp-aws-docusaurus:status
└── destroy-infra.md     # /yaccp-aws-docusaurus:destroy-infra

templates/
├── cloudfront-distribution.json
├── s3-bucket-policy.json
├── route53-alias.json
└── lambda-basic-auth.js
```

## Configuration Storage

Commands persist configuration to: `.claude/yaccp/aws-docusaurus/config.json`

```json
{
  "init": {
    "PROJECT_NAME": "...",
    "SITE_URL": "..."
  },
  "infra": {
    "S3_BUCKET": "...",
    "CLOUDFRONT_DISTRIBUTION_ID": "..."
  }
}
```

## Environment Variables

### Required for Infrastructure
- `SITE_NAME` - Resource naming prefix
- `DOMAIN` - Custom domain (e.g., docs.example.com)
- `HOSTED_ZONE_ID` - Route53 hosted zone ID
- `AWS_PROFILE` - AWS CLI profile
- `AWS_REGION` - Primary region

### Required for Deployment
- `S3_BUCKET` - Target S3 bucket
- `CLOUDFRONT_DISTRIBUTION_ID` - CloudFront distribution ID

## Maintenance Agents

Located in `.claude/agents/`:
- `plugin-validator` - Validate plugin structure
- `test-runner` - Execute validation tests
- `release-manager` - Manage releases and versioning
- `security-reviewer` - Security audits
- `changelog-updater` - Maintain changelog

## Security Model

- All S3 public access blocked
- HTTPS enforced (HTTP redirect)
- TLS 1.2 minimum
- OAI-only S3 access
- IAM least privilege for Lambda

## Supported Frameworks

| Framework | Build Command | Output Dir |
|-----------|---------------|------------|
| Docusaurus | `npm run build` | `build` |
| Next.js | `npm run build && npm run export` | `out` |
| Vite/Vue/React | `npm run build` | `dist` |
| Hugo | `hugo --minify` | `public` |
| Astro | `npm run build` | `dist` |
