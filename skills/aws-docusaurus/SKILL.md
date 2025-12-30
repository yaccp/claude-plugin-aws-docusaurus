---
name: aws-docusaurus
description: Deploy static sites to AWS. Use when "deploy to AWS", "S3 hosting", "CloudFront", "static site deployment".
---

# AWS Docusaurus

Deploy static sites to AWS infrastructure with S3, CloudFront, ACM, and Route53.

## When to Use

This skill applies when:
- User wants to deploy a static site to AWS
- User mentions S3, CloudFront, or static hosting
- User has a Docusaurus, Next.js, Astro, Vite, or Hugo project
- User needs HTTPS/SSL for a static site
- User wants multi-environment deployments (dev/staging/prod)

## Quick Start

Invoke the plugin:
```
/aws-docusaurus:action
```

This single command provides an interactive menu for all operations.

## Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Setup     │────▶│   Infra     │────▶│   Deploy    │
│             │     │             │     │             │
│ • Project   │     │ • S3 Bucket │     │ • Build     │
│ • Framework │     │ • CloudFront│     │ • Upload    │
│ • AWS Env   │     │ • SSL Cert  │     │ • Invalidate│
└─────────────┘     │ • DNS       │     └─────────────┘
                    └─────────────┘
```

## AWS Architecture

```
Route53 (DNS)
    │
    ▼
CloudFront (CDN + HTTPS)
    │
    ├── Lambda@Edge (optional Basic Auth)
    │
    ▼
S3 Bucket (private, OAI access)
```

## Multi-Environment Support

The plugin supports multiple AWS environments:
- **dev**: Development (fast iteration)
- **staging**: Pre-production validation
- **prod**: Production (separate AWS account recommended)

Configuration stored in `.claude/yaccp/aws-docusaurus/config.json`.

Override with: `export PLUGIN_ENV=staging`

## Supported Frameworks

| Framework | Build Command | Output Dir |
|-----------|---------------|------------|
| Docusaurus | `npm run build` | `build` |
| Next.js | `npm run build` | `out` |
| Astro | `npm run build` | `dist` |
| Vite/Vue/React | `npm run build` | `dist` |
| Hugo | `hugo --minify` | `public` |

## Cache Strategy

| File Type | TTL | Cache-Control |
|-----------|-----|---------------|
| JS, CSS, images | 1 year | `max-age=31536000, immutable` |
| HTML, JSON | 0 | `max-age=0, must-revalidate` |

## Security

- S3 bucket is private (no public access)
- CloudFront OAI for S3 access
- HTTPS enforced (HTTP redirects)
- TLS 1.2 minimum
- Optional Basic Auth via Lambda@Edge

## Prerequisites

- AWS CLI configured
- Node.js >= 18
- Route53 hosted zone for domain
- AWS permissions: S3, CloudFront, ACM, Lambda, Route53
