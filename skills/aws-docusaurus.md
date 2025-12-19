# AWS Docusaurus Skill

Complete workflow for deploying static sites to AWS with S3, CloudFront, and optional authentication.

## Overview

AWS Docusaurus automates the entire process of deploying static sites (Docusaurus, Next.js, Vite, Hugo, etc.) to AWS infrastructure with:

- **S3** for storage (private, secure)
- **CloudFront** for CDN and HTTPS
- **ACM** for SSL certificates
- **Route53** for DNS
- **Lambda@Edge** for optional Basic Auth

## Quick Start

### 1. Initialize Project

```bash
export PROJECT_NAME="my-docs"
export SITE_TITLE="My Documentation"
export SITE_URL="https://docs.example.com"
```

Then ask: "Initialize a Docusaurus project with AWS Docusaurus"

### 2. Create Infrastructure

```bash
export SITE_NAME="my-docs"
export DOMAIN="docs.example.com"
export HOSTED_ZONE_ID="Z1234567890ABC"
export AWS_PROFILE="default"
export AWS_REGION="eu-west-3"

# Optional Basic Auth
export AUTH_USERNAME="admin"
export AUTH_PASSWORD="SecretPass123!"
```

Then ask: "Create AWS infrastructure with AWS Docusaurus"

### 3. Deploy

```bash
export S3_BUCKET="my-docs"
export CLOUDFRONT_DISTRIBUTION_ID="E1234567890ABC"
export BUILD_COMMAND="npm run build"
export BUILD_DIR="build"
```

Then ask: "Deploy my site with AWS Docusaurus"

## Available Commands

| Command | Description |
|---------|-------------|
| `/aws-docusaurus init` | Initialize Docusaurus project |
| `/aws-docusaurus infra` | Create AWS infrastructure |
| `/aws-docusaurus deploy` | Build and deploy site |
| `/aws-docusaurus status` | Check infrastructure status |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         WORKFLOW                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐      │
│   │    INIT     │────▶│    INFRA    │────▶│   DEPLOY    │      │
│   │             │     │             │     │             │      │
│   │ • Docusaurus│     │ • S3 Bucket │     │ • Build     │      │
│   │ • Config    │     │ • CloudFront│     │ • S3 Sync   │      │
│   │ • deploy.sh │     │ • ACM Cert  │     │ • Invalidate│      │
│   │             │     │ • Route53   │     │             │      │
│   │             │     │ • Lambda    │     │             │      │
│   └─────────────┘     └─────────────┘     └─────────────┘      │
│                                                                 │
│                              │                                  │
│                              ▼                                  │
│                    ┌─────────────────┐                          │
│                    │   SITE LIVE     │                          │
│                    │ https://domain  │                          │
│                    └─────────────────┘                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## AWS Architecture

```
                         ┌─────────────┐
                         │   Route53   │
                         │  DNS Alias  │
                         └──────┬──────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────┐
│                      CloudFront CDN                           │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ Lambda@Edge (viewer-request) - Basic Auth (optional)   │  │
│  └─────────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ ACM Certificate (HTTPS) - TLS 1.2+                      │  │
│  └─────────────────────────────────────────────────────────┘  │
│  • HTTPS redirect  • Gzip compression  • Edge caching        │
└───────────────────────────────────────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────┐
                    │   S3 Bucket       │
                    │ (Private - OAI)   │
                    └───────────────────┘
```

## Cache Strategy

| File Type | TTL | Cache-Control |
|-----------|-----|---------------|
| JS, CSS, images | 1 year | `max-age=31536000, immutable` |
| HTML | 0 | `max-age=0, must-revalidate` |
| Service Worker | 0 | `max-age=0, must-revalidate` |
| sitemap.xml | 1 day | `max-age=86400` |

## Supported Frameworks

- Docusaurus
- Next.js (static export)
- Vite / Vue / React
- Hugo
- Astro
- Gatsby
- Any static site generator

## Security Features

- Private S3 bucket (no public access)
- CloudFront OAI for S3 access
- HTTPS enforced (HTTP redirect)
- TLS 1.2 minimum
- Optional Basic Authentication via Lambda@Edge

## Prerequisites

- AWS CLI configured with appropriate profile
- Node.js >= 20 (for Docusaurus)
- Route53 hosted zone for your domain
- AWS permissions: S3, CloudFront, ACM, Lambda, IAM, Route53
