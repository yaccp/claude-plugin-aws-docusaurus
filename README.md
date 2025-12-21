# AWS Docusaurus

> Deploy static sites to AWS with zero configuration headaches.

[![Yaccp Plugin](https://img.shields.io/badge/Yaccp-Plugin-blue)](https://github.com/yaccp/yaccp)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![AWS](https://img.shields.io/badge/AWS-S3%20%2B%20CloudFront-orange)](https://aws.amazon.com)

**AWS Docusaurus** is a Claude Code plugin that automates the complete deployment pipeline for static sites on AWS. From project initialization to production deployment, AWS Docusaurus handles S3, CloudFront, SSL certificates, DNS, and optional authentication.

## Features

- **One-command infrastructure** - Creates S3, CloudFront, ACM certificates, Route53 records
- **Optimized caching** - Smart cache headers for maximum performance
- **HTTPS by default** - Automatic SSL certificate provisioning
- **Optional Basic Auth** - Protect staging sites with Lambda@Edge
- **Multi-framework support** - Docusaurus, Next.js, Vite, Hugo, Astro, Gatsby
- **CI/CD ready** - GitHub Actions and GitLab CI examples included

## Quick Start

### Installation

```bash
# Add Yaccp marketplace
/plugin marketplace add yaccp/yaccp

# Install the plugin
/plugin install yaccp-aws-docusaurus
```

### Usage

```bash
# 1. Initialize a new Docusaurus project
/yaccp-aws-docusaurus:yaccp-aws-docusaurus-init

# 2. Create AWS infrastructure
/yaccp-aws-docusaurus:yaccp-aws-docusaurus-infra

# 3. Deploy
/yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy
```

## Commands

| Command | Description |
|---------|-------------|
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-env` | Manage AWS environments (dev/staging/prod) |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-init` | Initialize a new Docusaurus project pre-configured for AWS |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-infra` | Create complete AWS infrastructure (S3, CloudFront, ACM, Route53) |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy` | Build and deploy site with optimized caching |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-status` | Check infrastructure status and health |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-destroy-infra` | Destroy all AWS infrastructure |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-doctor` | Diagnose issues with plugin and AWS setup |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-issues` | Create a GitHub issue for this plugin |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server` | Start the local development server |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-stop-local-server` | Stop the local development server |
| `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-status-local-server` | Check local server status |

## Interactive Prompts

Each command guides you through configuration with interactive prompts:

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-init</strong></summary>

```
? Project name: my-docs
? Site title: My Documentation
? Site URL: https://docs.example.com
```

```
Configuration Summary
=====================
Project Name:  my-docs
Site Title:    My Documentation
Site URL:      https://docs.example.com
Tagline:       Documentation
Locale:        en

Proceed with initialization?
● Yes, create the project
○ No, let me change something
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-infra</strong></summary>

```
? Site name (S3 bucket): my-docs
? Domain: docs.example.com
? Route53 Hosted Zone ID: Z1234567890ABC
```

```
? Do you want to enable Basic Authentication?
○ Yes
● No
```

```
Infrastructure Configuration
============================
Site Name:       my-docs
Domain:          docs.example.com
Hosted Zone ID:  Z1234567890ABC
AWS Profile:     default
Basic Auth:      No

Resources to create:
• S3 Bucket: my-docs
• ACM Certificate: docs.example.com
• CloudFront Distribution
• Route53 A Record

Proceed?
● Yes, create infrastructure
○ No, let me change something
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy</strong></summary>

```
Detected framework: Docusaurus
```

```
Deployment Configuration
========================
Framework:       Docusaurus
Build Command:   npm run build
Build Directory: build
S3 Bucket:       my-docs
CloudFront ID:   E1234567890ABC

Cache Strategy:
• JS/CSS/Images: 1 year (immutable)
• HTML/JSON:     No cache

Proceed?
● Yes, build and deploy
○ No, let me change something
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-status</strong></summary>

```
AWS Docusaurus Status
=====================

CloudFront: E1234567890ABC
├── Status:  Deployed
├── Enabled: true
└── Domain:  d123456.cloudfront.net

S3 Bucket: my-docs
├── Status:  Accessible
├── Objects: 142
└── Size:    12.5 MB

Certificate:
├── Status:  ISSUED
└── Expires: 2025-12-20

Site Health: https://docs.example.com
├── Status:  200 OK
└── TTFB:    0.045s
```

```
? What would you like to do next?
○ Invalidate CloudFront cache
○ Redeploy site
● Nothing, done
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-destroy-infra</strong></summary>

```
⚠️  INFRASTRUCTURE DESTRUCTION
==============================

This will PERMANENTLY DELETE:

• CloudFront: E1234567890ABC
• S3 Bucket: my-docs (all objects!)
• Route53: docs.example.com
• ACM Certificate
• Origin Access Identity

⚠️  THIS ACTION CANNOT BE UNDONE!
```

```
? Are you sure you want to destroy all infrastructure?
● Yes, destroy everything
○ No, cancel
```

```
? Type 'destroy' to confirm: destroy
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-doctor</strong></summary>

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
└── Identity:     arn:aws:iam::***:user/deploy
```

```
AWS Resources:
├── S3 Bucket:
│   ├── Exists:   ✓
│   └── Objects:  142
├── CloudFront:
│   ├── Status:   Deployed
│   └── Enabled:  true
├── ACM Certificate:
│   └── Status:   ISSUED
└── Route53 Record:
    └── Exists:   ✓
```

```
Diagnostic Summary
==================

Status: 1 issue found

Prerequisites:     ✓ All OK
Configuration:     ✓ Found
AWS Resources:     ⚠️ 1 warning
IAM Permissions:   ✓ All OK
```

```
? What would you like to do next?
○ View detailed error logs
○ Create a GitHub issue
○ Run /yaccp-aws-docusaurus:yaccp-aws-docusaurus-status
● Nothing, I'll fix it myself
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-issues</strong></summary>

```
? What type of issue would you like to create?
○ Bug Report
○ Feature Request
○ Question
● Documentation
```

For Bug Report:
```
? Describe the bug: CloudFront creation fails
? Expected behavior: Should create successfully
? Which command? /yaccp-aws-docusaurus:yaccp-aws-docusaurus-infra
? Error message: AccessDenied...
```

```
Issue Preview
=============

Title: [Bug] CloudFront creation fails
Labels: bug

## Description
CloudFront creation fails with AccessDenied error.

## Expected Behavior
Should create successfully.

## Environment
- Command: /yaccp-aws-docusaurus:yaccp-aws-docusaurus-infra
- Plugin Version: 1.1.8

---

? Create this issue?
● Yes, create issue on GitHub
○ Edit title
○ Edit description
○ Cancel
```

```
Issue created successfully!

Issue #42: [Bug] CloudFront creation fails
URL: https://github.com/yaccp/claude-plugin-aws-docusaurus/issues/42
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server</strong></summary>

```
Detected: Docusaurus project
```

```
? A server is already running on port 3000. What would you like to do?
○ Stop it and start a new one
○ Use a different port
● Cancel
```

```
Local Development Server Started
================================

URL:     http://localhost:3000
PID:     12345
Status:  Running

The server will hot-reload on file changes.
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-status-local-server</strong></summary>

```
Local Development Server Status
================================

Status:      Running
URL:         http://localhost:3000
PID:         12345
Started:     2024-12-21T10:30:00Z
Uptime:      2h 15m
Health:      Healthy

Process Info:
├── CPU:     0.5%
├── Memory:  128 MB
└── Command: node docusaurus start
```

```
? What would you like to do?
○ Open in browser
○ Stop the server
○ View server logs
● Nothing, done
```
</details>

<details>
<summary><strong>/yaccp-aws-docusaurus:yaccp-aws-docusaurus-stop-local-server</strong></summary>

```
? Found local server running on port 3000 (PID: 12345). Stop it?
● Yes, stop the server
○ No, keep it running
```

```
Local Development Server Stopped
=================================

Port 3000 is now available.
```
</details>

## Architecture

![Architecture](assets/diagrams/architecture.svg)

## Workflow

![Workflow](assets/diagrams/workflow.svg)

## Multi-Environment Support

AWS Docusaurus supports multiple AWS environments for professional deployment workflows:

```
.claude/yaccp/aws-docusaurus/config.json
├── environments/
│   ├── dev      → Development (dev.example.com)
│   ├── staging  → Staging (staging.example.com)
│   └── prod     → Production (example.com)
└── currentEnvironment: "dev"
```

Each environment can have:
- Separate AWS accounts/profiles
- Different domains and hosted zones
- Independent S3 buckets and CloudFront distributions

Use `/yaccp-aws-docusaurus:yaccp-aws-docusaurus-env` to manage environments, or override with:
```bash
export PLUGIN_ENV=staging
/yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy
```

## Supported Frameworks

| Framework | Build Command | Output Directory |
|-----------|---------------|------------------|
| Docusaurus | `npm run build` | `build` |
| Next.js (static) | `npm run build && npm run export` | `out` |
| Vite / Vue / React | `npm run build` | `dist` |
| Hugo | `hugo --minify` | `public` |
| Astro | `npm run build` | `dist` |
| Gatsby | `gatsby build` | `public` |

## Security

AWS Docusaurus implements AWS security best practices:

- **Private S3 bucket** - No public access, OAI only
- **HTTPS enforced** - HTTP redirects to HTTPS
- **TLS 1.2 minimum** - Modern encryption standards
- **IAM least privilege** - Minimal required permissions
- **Lambda@Edge auth** - Optional password protection

## AWS Resources Created

| Resource | Description | Region |
|----------|-------------|--------|
| S3 Bucket | Static file storage | Your region |
| CloudFront Distribution | CDN | Global (Edge) |
| ACM Certificate | SSL/TLS | us-east-1 |
| Route53 A Record | DNS alias | Global |
| IAM Role | Lambda execution | Global |
| Lambda@Edge Function | Basic Auth (optional) | us-east-1 |
| Origin Access Identity | S3 access control | Global |

## Cost Estimation

Typical costs for a documentation site (~1000 pages, ~10GB transfer/month):

| Service | Estimated Cost/Month |
|---------|---------------------|
| S3 Storage | ~$0.50 |
| CloudFront | ~$1.00 |
| Route53 | ~$0.50 |
| Lambda@Edge | ~$0.00 (free tier) |
| **Total** | **~$2.00/month** |

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| 403 Forbidden | S3 policy issue | Check OAI configuration |
| Certificate not validating | DNS propagation | Wait 5-30 minutes |
| Stale content | Cache not invalidated | Run new invalidation |
| 502 Bad Gateway | Lambda@Edge error | Check CloudWatch logs (us-east-1) |
| Distribution stuck "InProgress" | Normal for new distributions | Wait 15-30 minutes |

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci && npm run build
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-3
      - run: aws s3 sync build/ s3://${{ secrets.S3_BUCKET }}/ --delete
      - run: aws cloudfront create-invalidation --distribution-id ${{ secrets.CF_ID }} --paths "/*"
```

---

## Advanced Usage

### Cache Strategy

| File Type | Cache TTL | Header | Rationale |
|-----------|-----------|--------|-----------|
| `*.js`, `*.css` | 1 year | `max-age=31536000, immutable` | Content-hashed filenames |
| Images, fonts | 1 year | `max-age=31536000, immutable` | Rarely change |
| `*.html` | 0 | `max-age=0, must-revalidate` | Always fetch latest |
| `sw.js` | 0 | `max-age=0, must-revalidate` | Service worker updates |
| `sitemap.xml` | 1 day | `max-age=86400` | Semi-static |
| `*.json` | 0 | `max-age=0, must-revalidate` | Page data |

### Environment Variables

#### Project Initialization

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `PROJECT_NAME` | Yes | Project directory name | `my-docs` |
| `SITE_TITLE` | Yes | Site title | `My Documentation` |
| `SITE_URL` | Yes | Production URL | `https://docs.example.com` |
| `SITE_TAGLINE` | No | Site tagline | `Amazing docs` |
| `ORG_NAME` | No | GitHub organization | `my-org` |
| `LOCALE` | No | Default locale | `en`, `fr` |

#### Infrastructure Creation

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `SITE_NAME` | Yes | Resource naming prefix | `my-docs` |
| `DOMAIN` | Yes | Custom domain | `docs.example.com` |
| `HOSTED_ZONE_ID` | Yes | Route53 hosted zone | `Z1234567890ABC` |
| `AWS_PROFILE` | No | AWS CLI profile | `default` |
| `AWS_REGION` | No | Primary AWS region | `eu-west-3` |
| `AUTH_USERNAME` | No | Basic auth username | `admin` |
| `AUTH_PASSWORD` | No | Basic auth password | `Secret123!` |

#### Deployment

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `S3_BUCKET` | Yes | S3 bucket name | `my-docs` |
| `CLOUDFRONT_DISTRIBUTION_ID` | Yes | CloudFront ID | `E1234567890ABC` |
| `BUILD_COMMAND` | No | Build command | `npm run build` |
| `BUILD_DIR` | No | Build output directory | `build` |

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

## Author

Created by [Cyril Feraudet](https://github.com/feraudet) - A [Yaccp](https://github.com/yaccp) plugin for Claude Code.
