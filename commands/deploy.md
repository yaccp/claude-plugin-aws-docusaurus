# AWS Docusaurus: Deploy Site

Deploys static site content to AWS S3 + CloudFront with optimized caching strategy.

## Prerequisites

- Infrastructure created by `/aws-docusaurus infra`
- AWS CLI configured
- Site ready to build

## Required Environment Variables

```bash
export S3_BUCKET="my-site"
export CLOUDFRONT_DISTRIBUTION_ID="E1234567890ABC"
export BUILD_COMMAND="npm run build"
export BUILD_DIR="build"
export AWS_PROFILE="default"
export AWS_REGION="eu-west-3"
```

## Optional Variables

```bash
export SITE_URL="https://site.example.com"
export AUTH_USERNAME="admin"      # if using Basic Auth
export AUTH_PASSWORD="secret"     # if using Basic Auth
```

## Cache Strategy

| File Type | Cache-Control | TTL | Rationale |
|-----------|---------------|-----|-----------|
| `*.js`, `*.css` | `max-age=31536000, immutable` | 1 year | Content-hashed |
| Images, fonts | `max-age=31536000, immutable` | 1 year | Static assets |
| `*.html` | `max-age=0, must-revalidate` | 0 | Always fresh |
| `sw.js` | `max-age=0, must-revalidate` | 0 | Service worker |
| `sitemap.xml` | `max-age=86400` | 1 day | Semi-static |
| `*.json` | `max-age=0, must-revalidate` | 0 | Dynamic data |

## Deployment Steps

### Step 1: Build Site

```bash
${BUILD_COMMAND}
```

Verify build directory exists.

### Step 2: Upload Static Assets (1-year cache)

Upload JS, CSS, images, fonts with immutable cache:

```bash
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "*.html" \
  --exclude "sw.js" \
  --exclude "sitemap.xml" \
  --exclude "*.json"
```

### Step 3: Upload HTML (no cache)

Upload HTML files with must-revalidate:

```bash
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
  --exclude "*" \
  --include "*.html" \
  --cache-control "public, max-age=0, must-revalidate" \
  --content-type "text/html; charset=utf-8"
```

### Step 4: Upload JSON and Sitemap

```bash
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
  --exclude "*" \
  --include "*.json" \
  --include "sitemap.xml" \
  --cache-control "public, max-age=0, must-revalidate"
```

### Step 5: Invalidate CloudFront Cache

```bash
aws cloudfront create-invalidation \
  --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --paths "/*"
```

## Framework Configurations

| Framework | BUILD_COMMAND | BUILD_DIR |
|-----------|---------------|-----------|
| Docusaurus | `npm run build` | `build` |
| Next.js (static) | `npm run build && npm run export` | `out` |
| Vite/Vue/React | `npm run build` | `dist` |
| Hugo | `hugo --minify` | `public` |
| Astro | `npm run build` | `dist` |
| Gatsby | `gatsby build` | `public` |

## Verification

```bash
# Check distribution status
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'Distribution.Status'

# Test site response
curl -I ${SITE_URL}

# Check cache headers
curl -I ${SITE_URL}/index.html 2>/dev/null | grep -i cache-control

# List S3 contents
aws s3 ls s3://${S3_BUCKET}/ --recursive --human-readable
```

## Deployment Time

- Build: Depends on project size
- S3 Sync: 10-60 seconds (depends on file count)
- CloudFront Invalidation: 1-5 minutes

## Rollback

```bash
# Redeploy previous version
git checkout <previous-commit>
${BUILD_COMMAND}
# Re-run deploy

# Or invalidate to clear bad cache
aws cloudfront create-invalidation \
  --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --paths "/*"
```

## CI/CD Integration

See `/aws-docusaurus status` for GitHub Actions and GitLab CI examples.
