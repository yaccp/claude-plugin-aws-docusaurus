---
description: Manage AWS environments (dev/staging/prod)
---

# AWS Docusaurus: Manage Environments

Manage AWS environments and profiles for multi-account deployments.

## Configuration Storage

Store environments in `.claude/yaccp/aws-docusaurus/config.json`:

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

### Step 1: Load Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

### Step 2: Select Action

Use AskUserQuestion:
"What would you like to do?"
- "List environments" - Show all configured environments
- "Switch environment" - Change current environment
- "Create new environment" - Add a new environment
- "Edit environment" - Modify existing environment
- "Delete environment" - Remove an environment
- "Set defaults" - Configure default values

### Step 3: Execute Action

#### List Environments

Display:
```
AWS Docusaurus Environments
===========================
Current: ${CURRENT_ENV}

  dev (Development)
    AWS Profile:  company-dev
    AWS Account:  111111111111
    S3 Bucket:    mysite-dev
    Domain:       dev.example.com

  staging (Staging)
    AWS Profile:  company-staging
    AWS Account:  222222222222
    S3 Bucket:    mysite-staging
    Domain:       staging.example.com

  prod (Production) [PROTECTED]
    AWS Profile:  company-prod
    AWS Account:  333333333333
    S3 Bucket:    mysite-prod
    Domain:       example.com
```

#### Switch Environment

Use AskUserQuestion:
"Which environment do you want to use?"
- List all available environments from config
- Show current environment with "(current)" suffix

After selection:
```
Switched to: ${ENV_NAME}
AWS Profile: ${AWS_PROFILE}
AWS Account: ${AWS_ACCOUNT_ID}

All commands will now use this environment.
To override temporarily: export PLUGIN_ENV=other-env
```

#### Create New Environment

Use AskUserQuestion:
"Environment identifier? (e.g., dev, staging, prod, feature-x)"

Then prompt for each required variable:

**Required:**
- **name**: Display name (e.g., "Development")
- **AWS_PROFILE**: AWS CLI profile name
- **AWS_REGION**: AWS region (default from config.defaults)
- **AWS_ACCOUNT_ID**: AWS Account ID (12 digits)

**Infrastructure (if already provisioned):**
- **S3_BUCKET**: S3 bucket name
- **CLOUDFRONT_DISTRIBUTION_ID**: CloudFront distribution ID
- **DOMAIN**: Custom domain
- **HOSTED_ZONE_ID**: Route53 hosted zone ID

Use AskUserQuestion for each missing value.

Display summary and confirm:
```
New Environment: ${ENV_ID}
========================
Name:           ${NAME}
AWS Profile:    ${AWS_PROFILE}
AWS Region:     ${AWS_REGION}
AWS Account:    ${AWS_ACCOUNT_ID}
S3 Bucket:      ${S3_BUCKET}
CloudFront ID:  ${CLOUDFRONT_ID}
Domain:         ${DOMAIN}

Create this environment?
```

Use AskUserQuestion:
- "Yes, create environment"
- "No, cancel"

#### Edit Environment

Use AskUserQuestion:
"Which environment do you want to edit?"
- List all environments

Then:
Use AskUserQuestion:
"Which field do you want to edit?"
- List all fields with current values
- Option "All fields" to re-enter everything

#### Delete Environment

Use AskUserQuestion:
"Which environment do you want to delete?"
- List all environments except current

If deleting prod:
```
WARNING: You are about to delete the production environment.
This action cannot be undone.
```

Use AskUserQuestion:
- "Yes, I understand and want to delete"
- "No, cancel"

### Step 4: Save Configuration

After any modification, save to `.claude/yaccp/aws-docusaurus/config.json`:

```bash
mkdir -p .claude/yaccp/aws-docusaurus
```

Write updated config.json.

### Step 5: Show Next Steps

```
Environment configuration updated!

Current environment: ${CURRENT_ENV}
Config saved to: .claude/yaccp/aws-docusaurus/config.json

Available commands:
• /yaccp-aws-docusaurus:infra   - Create infrastructure for current env
• /yaccp-aws-docusaurus:deploy  - Deploy to current env
• /yaccp-aws-docusaurus:status  - Check current env status

To switch environment:
• /yaccp-aws-docusaurus:env
• Or: export PLUGIN_ENV=staging
```

## Environment Variable Override

Users can override the current environment temporarily:

```bash
export PLUGIN_ENV=staging
/yaccp-aws-docusaurus:deploy  # Will use staging
```

This is useful for CI/CD pipelines.

## Best Practices

1. **Separate AWS Accounts**: Use different AWS accounts for prod vs dev/staging
2. **Naming Convention**: Use consistent prefixes (e.g., `mysite-dev`, `mysite-staging`, `mysite-prod`)
3. **Protected Environments**: Mark prod as protected to require extra confirmation
4. **Defaults**: Set sensible defaults for region and build settings
