---
description: Build and deploy site to S3 with CloudFront cache invalidation
---

# AWS Docusaurus: Deploy Site

Deploy static site to AWS S3 + CloudFront for the selected environment.

## Configuration Storage

Store and retrieve configuration from `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "environments": {
    "dev": {
      "AWS_PROFILE": "company-dev",
      "AWS_REGION": "eu-west-1",
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
  }
}
```

## Interactive Flow

### Step 0: Resolve Environment

1. Check `$PLUGIN_ENV` for environment override
2. Load config and get `currentEnvironment`
3. If no current environment set, use AskUserQuestion:
   "Which environment do you want to deploy to?"
   - "dev" (Development)
   - "staging" (Staging)
   - "prod" (Production)

4. Load variables from `environments[selectedEnv]`
5. Display: "Using environment: ${ENV_NAME} (${AWS_ACCOUNT_ID})"

### Step 1: Load Saved Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

Also check if values exist in `infra` section (S3_BUCKET, CLOUDFRONT_DISTRIBUTION_ID).

### Step 2: Auto-Detect Framework

Check for framework files:
```bash
ls docusaurus.config.* next.config.* vite.config.* astro.config.* gatsby-config.* hugo.toml 2>/dev/null
```

| Framework | BUILD_COMMAND | BUILD_DIR |
|-----------|---------------|-----------|
| Docusaurus | `npm run build` | `build` |
| Next.js | `npm run build` | `out` |
| Vite | `npm run build` | `dist` |
| Astro | `npm run build` | `dist` |
| Gatsby | `gatsby build` | `public` |
| Hugo | `hugo --minify` | `public` |

### Step 3: Check and Prompt for Variables

For each variable, check in this order:
1. Environment variable
2. Saved config (`deploy` section, then `infra` section)
3. Auto-detected value (for BUILD_COMMAND, BUILD_DIR)
4. If not found, use AskUserQuestion

**Required:**
- **S3_BUCKET**: S3 bucket name
- **CLOUDFRONT_DISTRIBUTION_ID**: CloudFront ID (e.g., "E1234567890ABC")

**Auto-detected or ask:**
- **BUILD_COMMAND**: Build command
- **BUILD_DIR**: Build output directory

**Optional:**
- **AWS_PROFILE**: Default "default"
- **AWS_REGION**: Default "eu-west-3"

### Step 4: Display Summary and Confirm

```
Deployment Configuration
========================
Framework:       ${FRAMEWORK}
Build Command:   ${BUILD_COMMAND}
Build Directory: ${BUILD_DIR}
S3 Bucket:       ${S3_BUCKET}
CloudFront ID:   ${CLOUDFRONT_DISTRIBUTION_ID}
AWS Profile:     ${AWS_PROFILE}

Cache Strategy:
• JS/CSS/Images: 1 year (immutable)
• HTML/JSON:     No cache

Proceed?
```

Use AskUserQuestion:
- "Yes, build and deploy"
- "No, let me change something"

### Step 5: Save Configuration

After confirmation, save to `.claude/yaccp/aws-docusaurus/config.json`:

```bash
mkdir -p .claude/yaccp/aws-docusaurus
```

Write/update config.json with deploy section.

### Step 6: Execute Deployment

1. Build:
   ```bash
   ${BUILD_COMMAND}
   ```

2. Upload static assets (1-year cache):
   ```bash
   aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
     --delete \
     --cache-control "public, max-age=31536000, immutable" \
     --exclude "*.html" --exclude "*.json" --exclude "sw.js"
   ```

3. Upload HTML (no cache):
   ```bash
   aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
     --exclude "*" --include "*.html" \
     --cache-control "public, max-age=0, must-revalidate"
   ```

4. Invalidate CloudFront:
   ```bash
   aws cloudfront create-invalidation \
     --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
     --paths "/*"
   ```

### Step 7: Show Results

```
Deployment successful!
Configuration saved to .claude/yaccp/aws-docusaurus/config.json

Site URL:        https://${DOMAIN}
Files uploaded:  ${FILE_COUNT}
Invalidation:    ${INVALIDATION_ID}

Check status: /yaccp-aws-docusaurus:status
```
