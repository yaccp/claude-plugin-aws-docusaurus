# AWS Docusaurus: Deploy Site

Deploys static site content to AWS S3 + CloudFront with optimized caching strategy.

## Interactive Configuration

Before proceeding, check if required environment variables are set. If any are missing, ask the user for the values using AskUserQuestion.

### Required Variables Check

Check these environment variables and prompt for missing ones:

1. **S3_BUCKET** - S3 bucket name (e.g., "my-site")
2. **CLOUDFRONT_DISTRIBUTION_ID** - CloudFront distribution ID (e.g., "E1234567890ABC")
3. **BUILD_DIR** - Build output directory (default based on framework detection)
4. **AWS_PROFILE** - AWS CLI profile (default: "default")
5. **AWS_REGION** - AWS region (default: "eu-west-3")

### Auto-Detection

Try to auto-detect:
- **BUILD_COMMAND**: Detect from package.json scripts
- **BUILD_DIR**: Detect based on framework (build, dist, out, public)
- **Framework**: Check for docusaurus.config.*, next.config.*, vite.config.*, etc.

### Framework Detection Table

| Framework | Detection | BUILD_COMMAND | BUILD_DIR |
|-----------|-----------|---------------|-----------|
| Docusaurus | docusaurus.config.* | `npm run build` | `build` |
| Next.js | next.config.* | `npm run build` | `out` |
| Vite | vite.config.* | `npm run build` | `dist` |
| Vue CLI | vue.config.* | `npm run build` | `dist` |
| Create React App | react-scripts in package.json | `npm run build` | `build` |
| Hugo | config.toml/hugo.toml | `hugo --minify` | `public` |
| Astro | astro.config.* | `npm run build` | `dist` |
| Gatsby | gatsby-config.* | `gatsby build` | `public` |

## Execution Flow

1. Check environment variables
2. Auto-detect framework and build settings
3. Use AskUserQuestion for any missing required variables
4. Confirm settings before deploying
5. Build the site
6. Deploy to S3 with optimized cache headers
7. Invalidate CloudFront cache
8. Show deployment summary

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

## Verification

After deployment, verify:

```bash
# Check distribution status
aws cloudfront get-distribution \
  --id ${CLOUDFRONT_DISTRIBUTION_ID} \
  --query 'Distribution.Status'

# Test site response
curl -I ${SITE_URL}

# Check cache headers
curl -I ${SITE_URL}/index.html 2>/dev/null | grep -i cache-control
```

## Rollback

If issues occur:

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

## Next Steps

Run `/aws-docusaurus:status` to monitor your deployment.
