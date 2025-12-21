# AWS Docusaurus - Claude Context

## Plugin Overview

AWS Docusaurus automates static site deployment to AWS. It creates and manages:
- S3 bucket (private, OAI access only)
- CloudFront CDN distribution
- ACM SSL certificate (us-east-1)
- Route53 DNS alias records
- Lambda@Edge Basic Auth (optional)

## Multi-Environment Support

This plugin supports multiple AWS environments/accounts:

```
.claude/yaccp/aws-docusaurus/config.json
├── environments/
│   ├── dev      → AWS Account 111111111111
│   ├── staging  → AWS Account 222222222222
│   └── prod     → AWS Account 333333333333
└── currentEnvironment: "dev"
```

Use `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-env` to manage environments.

Override temporarily with: `export PLUGIN_ENV=staging`

## Commands

| Command | Purpose |
|---------|---------|
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-env` | Manage AWS environments (dev/staging/prod) |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-init` | Create new Docusaurus project with AWS-ready config |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-infra` | Provision complete AWS infrastructure |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy` | Build and deploy to S3 + invalidate CloudFront |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-status` | Check infrastructure health and status |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-destroy-infra` | Destroy all AWS infrastructure |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-doctor` | Diagnose issues with plugin and AWS setup |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-issues` | Create a GitHub issue for this plugin |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server` | Start the local development server |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-stop-local-server` | Stop the local development server |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-status-local-server` | Check local server status |

## Key Files

```
.claude-plugin/
├── plugin.json          # Plugin metadata (name, version)
└── marketplace.json     # Marketplace listing

commands/
├── env.md                    # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-env
├── init.md                   # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-init
├── infra.md                  # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-infra
├── deploy.md                 # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy
├── status.md                 # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-status
├── destroy-infra.md          # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-destroy-infra
├── doctor.md                 # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-doctor
├── issues.md                 # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-issues
├── start-local-server.md     # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server
├── stop-local-server.md      # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-stop-local-server
└── status-local-server.md    # /yaccp-aws-docusaurus:yaccp-aws-docusaurus-status-local-server

assets/
├── diagrams/*.svg       # Architecture diagrams
└── previews/*.gif       # Interaction previews

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
  "environments": {
    "dev": {
      "AWS_PROFILE": "company-dev",
      "AWS_ACCOUNT_ID": "111111111111",
      "S3_BUCKET": "mysite-dev",
      "CLOUDFRONT_DISTRIBUTION_ID": "E1DEV...",
      "DOMAIN": "dev.example.com"
    },
    "staging": { ... },
    "prod": { ... }
  },
  "currentEnvironment": "dev",
  "defaults": {
    "AWS_REGION": "eu-west-1",
    "BUILD_COMMAND": "npm run build",
    "BUILD_DIR": "build"
  },
  "localServer": {
    "PORT": "3000",
    "HOST": "localhost",
    "PID": null,
    "STARTED_AT": null
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
- `preview-generator` - Generate GIF previews of AskUserQuestion flows
- `diagram-updater` - Update Mermaid diagrams and regenerate SVGs

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
