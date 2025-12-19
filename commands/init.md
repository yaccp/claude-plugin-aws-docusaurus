# StaticForge: Initialize Project

Initialize a new Docusaurus project pre-configured for AWS deployment.

## Required Environment Variables

```bash
export PROJECT_NAME="my-docs"                    # Directory name
export SITE_TITLE="My Documentation"             # Site title
export SITE_URL="https://docs.example.com"       # Production URL
```

## Optional Environment Variables

```bash
export SITE_TAGLINE="Documentation for my project"
export ORG_NAME="my-org"                         # GitHub org
export LOCALE="en"                               # fr, en, de, etc.
export S3_BUCKET="my-docs-bucket"                # For deploy.sh
export CLOUDFRONT_DISTRIBUTION_ID="E1234..."     # For deploy.sh
export AWS_PROFILE="default"
export AWS_REGION="eu-west-3"
```

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

1. Run `/staticforge infra` to create AWS infrastructure
2. Run `/staticforge deploy` to deploy your site
