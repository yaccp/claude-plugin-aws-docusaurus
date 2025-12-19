# StaticForge

> Deploy static sites to AWS with zero configuration headaches.

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![AWS](https://img.shields.io/badge/AWS-S3%20%2B%20CloudFront-orange)](https://aws.amazon.com)

**StaticForge** is a Claude Code plugin that automates the complete deployment pipeline for static sites on AWS. From project initialization to production deployment, StaticForge handles S3, CloudFront, SSL certificates, DNS, and optional authentication.

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
claude plugins install staticforge
```

### Usage

```bash
# 1. Initialize a new Docusaurus project
export PROJECT_NAME="my-docs"
export SITE_TITLE="My Documentation"
export SITE_URL="https://docs.example.com"
# Ask Claude: "Initialize project with /staticforge init"

# 2. Create AWS infrastructure
export SITE_NAME="my-docs"
export DOMAIN="docs.example.com"
export HOSTED_ZONE_ID="Z1234567890ABC"
# Ask Claude: "Create infrastructure with /staticforge infra"

# 3. Deploy
export S3_BUCKET="my-docs"
export CLOUDFRONT_DISTRIBUTION_ID="E1234567890ABC"
# Ask Claude: "Deploy with /staticforge deploy"
```

## Commands

| Command | Description |
|---------|-------------|
| `/staticforge init` | Initialize a new Docusaurus project pre-configured for AWS |
| `/staticforge infra` | Create complete AWS infrastructure (S3, CloudFront, ACM, Route53) |
| `/staticforge deploy` | Build and deploy site with optimized caching |
| `/staticforge status` | Check infrastructure status and health |

## Architecture

```
                              ┌──────────────┐
                              │   Browser    │
                              └──────┬───────┘
                                     │ HTTPS
                              ┌──────▼───────┐
                              │   Route53    │
                              │  DNS Alias   │
                              └──────┬───────┘
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                           CloudFront CDN                                │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │            Lambda@Edge (Basic Auth) - Optional                     │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │               ACM Certificate (TLS 1.2+)                           │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  • Global edge locations        • Gzip/Brotli compression              │
│  • HTTP → HTTPS redirect        • Custom error pages (SPA)             │
│  • Smart caching                • DDoS protection                       │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ OAI
                              ┌──────▼───────┐
                              │  S3 Bucket   │
                              │  (Private)   │
                              └──────────────┘
```

## Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         StaticForge Workflow                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│    ┌───────────┐         ┌───────────┐         ┌───────────┐           │
│    │   INIT    │────────▶│   INFRA   │────────▶│  DEPLOY   │           │
│    │           │         │           │         │           │           │
│    │ Docusaurus│         │ S3 Bucket │         │ npm build │           │
│    │ config.ts │         │ CloudFront│         │ S3 sync   │           │
│    │ deploy.sh │         │ ACM Cert  │         │ Invalidate│           │
│    │           │         │ Route53   │         │           │           │
│    │  ~2 min   │         │ Lambda@E  │         │  ~2 min   │           │
│    │           │         │           │         │           │           │
│    │           │         │ ~30 min   │         │           │           │
│    └───────────┘         └───────────┘         └───────────┘           │
│                                                       │                 │
│                                                       ▼                 │
│                                            ┌─────────────────┐          │
│                                            │   SITE LIVE!    │          │
│                                            │ https://domain  │          │
│                                            └─────────────────┘          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Cache Strategy

StaticForge implements an optimal caching strategy:

| File Type | Cache TTL | Header | Rationale |
|-----------|-----------|--------|-----------|
| `*.js`, `*.css` | 1 year | `max-age=31536000, immutable` | Content-hashed filenames |
| Images, fonts | 1 year | `max-age=31536000, immutable` | Rarely change |
| `*.html` | 0 | `max-age=0, must-revalidate` | Always fetch latest |
| `sw.js` | 0 | `max-age=0, must-revalidate` | Service worker updates |
| `sitemap.xml` | 1 day | `max-age=86400` | Semi-static |
| `*.json` | 0 | `max-age=0, must-revalidate` | Page data |

## Environment Variables

### Project Initialization

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `PROJECT_NAME` | Yes | Project directory name | `my-docs` |
| `SITE_TITLE` | Yes | Site title | `My Documentation` |
| `SITE_URL` | Yes | Production URL | `https://docs.example.com` |
| `SITE_TAGLINE` | No | Site tagline | `Amazing docs` |
| `ORG_NAME` | No | GitHub organization | `my-org` |
| `LOCALE` | No | Default locale | `en`, `fr` |

### Infrastructure Creation

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `SITE_NAME` | Yes | Resource naming prefix | `my-docs` |
| `DOMAIN` | Yes | Custom domain | `docs.example.com` |
| `HOSTED_ZONE_ID` | Yes | Route53 hosted zone | `Z1234567890ABC` |
| `AWS_PROFILE` | Yes | AWS CLI profile | `default` |
| `AWS_REGION` | Yes | Primary AWS region | `eu-west-3` |
| `AUTH_USERNAME` | No | Basic auth username | `admin` |
| `AUTH_PASSWORD` | No | Basic auth password | `Secret123!` |

### Deployment

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `S3_BUCKET` | Yes | S3 bucket name | `my-docs` |
| `CLOUDFRONT_DISTRIBUTION_ID` | Yes | CloudFront ID | `E1234567890ABC` |
| `BUILD_COMMAND` | Yes | Build command | `npm run build` |
| `BUILD_DIR` | Yes | Build output directory | `build` |

## Supported Frameworks

| Framework | BUILD_COMMAND | BUILD_DIR |
|-----------|---------------|-----------|
| Docusaurus | `npm run build` | `build` |
| Next.js (static) | `npm run build && npm run export` | `out` |
| Vite / Vue / React | `npm run build` | `dist` |
| Hugo | `hugo --minify` | `public` |
| Astro | `npm run build` | `dist` |
| Gatsby | `gatsby build` | `public` |

## Security

StaticForge implements AWS security best practices:

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

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

Created with Claude Code by Claude Feraudet.

---

**StaticForge** - Forge your static sites into the cloud.
