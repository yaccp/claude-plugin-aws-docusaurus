---
description: Initialize a new Docusaurus project pre-configured for AWS deployment
---

# AWS Docusaurus: Initialize Project

Initialize a new Docusaurus project pre-configured for AWS deployment.

## Configuration Storage

Store and retrieve configuration from `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "init": {
    "PROJECT_NAME": "...",
    "SITE_TITLE": "...",
    "SITE_URL": "...",
    "SITE_TAGLINE": "...",
    "LOCALE": "...",
    "AWS_REGION": "..."
  }
}
```

## Interactive Flow

### Step 1: Load Saved Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

### Step 2: Check and Prompt for Variables

For each variable, check in this order:
1. Environment variable (`echo $VAR`)
2. Saved config (`.claude/yaccp/aws-docusaurus/config.json`)
3. If not found, use AskUserQuestion to prompt

**Required:**
- **PROJECT_NAME**: Directory/project name (e.g., "my-docs")
- **SITE_TITLE**: Site title (e.g., "My Documentation")
- **SITE_URL**: Production URL (e.g., "https://docs.example.com")

**Optional (with defaults):**
- **SITE_TAGLINE**: Default "Documentation"
- **LOCALE**: Default "en"
- **AWS_REGION**: Default "eu-west-3"

### Step 3: Display Summary and Confirm

```
Configuration Summary
=====================
Project Name:  ${PROJECT_NAME}
Site Title:    ${SITE_TITLE}
Site URL:      ${SITE_URL}
Tagline:       ${SITE_TAGLINE}
Locale:        ${LOCALE}
AWS Region:    ${AWS_REGION}

Proceed with initialization?
```

Use AskUserQuestion:
- "Yes, create the project"
- "No, let me change something"

### Step 4: Save Configuration

After confirmation, save to `.claude/yaccp/aws-docusaurus/config.json`:

```bash
mkdir -p .claude/yaccp/aws-docusaurus
```

Write/update config.json with the init section containing all values.

### Step 5: Execute Initialization

1. Create Docusaurus project:
   ```bash
   npx create-docusaurus@latest ${PROJECT_NAME} classic --typescript
   cd ${PROJECT_NAME}
   npm install
   ```

2. Configure docusaurus.config.ts
3. Create deploy.sh script
4. Configure .gitignore
5. Create initial documentation

### Step 6: Show Next Steps

```
Project created successfully!
Configuration saved to .claude/yaccp/aws-docusaurus/config.json

Next steps:
1. cd ${PROJECT_NAME}
2. npm start (preview locally)
3. /yaccp-aws-docusaurus:infra (create AWS infrastructure)
4. /yaccp-aws-docusaurus:deploy (deploy)
```

## Project Structure

```
${PROJECT_NAME}/
├── docusaurus.config.ts
├── sidebars.ts
├── package.json
├── deploy.sh
├── .gitignore
├── docs/intro.md
├── src/
│   ├── css/custom.css
│   └── pages/index.tsx
└── static/img/
```
