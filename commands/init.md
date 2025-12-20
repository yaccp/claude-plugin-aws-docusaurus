# AWS Docusaurus: Initialize Project

Initialize a new Docusaurus project pre-configured for AWS deployment.

## Interactive Configuration

Before proceeding, check if required environment variables are set. If any are missing, ask the user for the values using AskUserQuestion.

### Required Variables Check

Check these environment variables and prompt for missing ones:

1. **PROJECT_NAME** - Directory/project name (e.g., "my-docs")
2. **SITE_TITLE** - Site title displayed in header (e.g., "My Documentation")
3. **SITE_URL** - Production URL with https:// (e.g., "https://docs.example.com")

### Optional Variables (ask if user wants to customize)

- **SITE_TAGLINE** - Tagline under title (default: "Documentation")
- **ORG_NAME** - GitHub organization (default: derived from URL)
- **LOCALE** - Site language: en, fr, de, etc. (default: "en")
- **AWS_REGION** - AWS region (default: "eu-west-3")

## Execution Flow

1. Check environment variables
2. If any required variable is missing, use AskUserQuestion to prompt the user
3. Confirm configuration with user before proceeding
4. Execute the initialization steps

## What Gets Created

```
${PROJECT_NAME}/
├── docusaurus.config.ts      # Pre-configured for production
├── sidebars.ts               # Sidebar configuration
├── package.json              # Dependencies + scripts
├── deploy.sh                 # AWS deployment script
├── .gitignore                # Proper ignores
├── docs/
│   └── intro.md              # First documentation page
├── src/
│   ├── css/
│   │   └── custom.css        # Custom styling
│   └── pages/
│       └── index.tsx         # Homepage
└── static/
    └── img/                  # Static assets
```

## Execution Steps

### Step 1: Create Docusaurus Project

```bash
npx create-docusaurus@latest ${PROJECT_NAME} classic --typescript
cd ${PROJECT_NAME}
npm install
```

### Step 2: Configure docusaurus.config.ts

Replace with production-ready settings including:
- Site URL and base configuration
- SEO-optimized meta tags
- Dark mode support
- Prism syntax highlighting
- Build optimizations

### Step 3: Create deploy.sh

Generate deployment script with:
- Optimized cache headers per file type
- S3 sync with proper exclusions
- CloudFront invalidation

### Step 4: Configure .gitignore

Add proper ignores for:
- node_modules, build, .docusaurus
- IDE files, OS files
- Environment files

### Step 5: Create Initial Documentation

Generate starter docs/intro.md with:
- Getting started guide
- Local development instructions
- Build and deploy commands

## Verification

```bash
# Start development server
npm start

# Build for production
npm run build

# Serve production build locally
npm run serve
```

## Next Steps

1. Run `/aws-docusaurus:infra` to create AWS infrastructure
2. Run `/aws-docusaurus:deploy` to deploy your site
