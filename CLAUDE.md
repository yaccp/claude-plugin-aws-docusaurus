# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Plugin Overview

**AWS Docusaurus** deploys static sites to AWS infrastructure:
- S3 bucket (private, OAI access)
- CloudFront CDN with HTTPS
- ACM SSL certificate (us-east-1)
- Route53 DNS alias
- Lambda@Edge Basic Auth (optional)

## Command

Single entry point with interactive menu:

```
/aws-docusaurus:aws-docusaurus
```

This command handles all operations through AskUserQuestion:
- First-time setup wizard
- Project initialization (Docusaurus, Next.js, Astro, Vite, Hugo)
- Multi-environment management (dev/staging/prod)
- Infrastructure provisioning
- Deployment with cache optimization
- Status monitoring
- Diagnostics and troubleshooting
- Infrastructure destruction

## Configuration

All configuration stored in `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "environments": {
    "dev": {
      "name": "Development",
      "AWS_PROFILE": "company-dev",
      "AWS_REGION": "eu-west-1",
      "AWS_ACCOUNT_ID": "111111111111",
      "S3_BUCKET": "mysite-dev",
      "CLOUDFRONT_DISTRIBUTION_ID": "E1DEV...",
      "DOMAIN": "dev.example.com",
      "HOSTED_ZONE_ID": "Z1DEV..."
    }
  },
  "currentEnvironment": "dev",
  "defaults": {
    "BUILD_COMMAND": "npm run build",
    "BUILD_DIR": "build"
  }
}
```

## Environment Override

```bash
export PLUGIN_ENV=staging
```

## Key Files

```
aws-docusaurus/
├── .claude-plugin/
│   └── plugin.json       # Plugin metadata
├── commands/
│   └── aws-docusaurus.md         # Single entry point command
├── skills/
│   └── aws-docusaurus/
│       └── SKILL.md
├── templates/            # AWS config templates
└── CLAUDE.md
```

## Supported Frameworks

| Framework | Build Command | Output Dir |
|-----------|---------------|------------|
| Docusaurus | `npm run build` | `build` |
| Next.js | `npm run build` | `out` |
| Astro | `npm run build` | `dist` |
| Vite/Vue/React | `npm run build` | `dist` |
| Hugo | `hugo --minify` | `public` |

## Security

- All S3 public access blocked
- HTTPS enforced (TLS 1.2+)
- OAI-only S3 access
- Optional Basic Auth via Lambda@Edge
