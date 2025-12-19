# Installation Guide

## Method 1: Yaccp Marketplace (Recommended)

### Step 1: Add the Yaccp marketplace

```bash
/plugin marketplace add yaccp/yaccp
```

### Step 2: Install the plugin

```bash
/plugin install aws-docusaurus
```

### Step 3: Verify installation

```bash
/help
```

You should see the AWS Docusaurus commands:
- `/aws-docusaurus init`
- `/aws-docusaurus infra`
- `/aws-docusaurus deploy`
- `/aws-docusaurus status`

---

## Method 2: Local Installation (Development)

### Clone and install locally

```bash
# Clone the repository
git clone https://github.com/yaccp/claude-plugin-aws-docusaurus.git

# Add as local plugin
/plugin add-local ./aws-docusaurus
```

---

## Method 3: Direct from GitHub URL

```bash
/plugin install github:yaccp/claude-plugin-aws-docusaurus
```

---

## Updating the Plugin

```bash
# Check for updates
/plugin list

# Update to latest version
/plugin update aws-docusaurus
```

---

## Uninstalling

```bash
/plugin uninstall aws-docusaurus
```

---

## Troubleshooting

### Plugin not found

Ensure you've added the Yaccp marketplace first:
```bash
/plugin marketplace add yaccp/yaccp
```

### Commands not appearing

Restart Claude Code after installation:
```bash
exit
claude
```

### Permission errors

Ensure your Claude Code has network access to GitHub.

---

## Requirements

- Claude Code CLI (latest version)
- AWS CLI configured with valid credentials
- Node.js >= 20 (for Docusaurus projects)

---

## Quick Start After Installation

```bash
# Set environment variables
export PROJECT_NAME="my-docs"
export SITE_TITLE="My Documentation"
export SITE_URL="https://docs.example.com"

# Initialize project
/aws-docusaurus init

# Set AWS variables
export SITE_NAME="my-docs"
export DOMAIN="docs.example.com"
export HOSTED_ZONE_ID="Z1234567890ABC"
export AWS_PROFILE="default"
export AWS_REGION="eu-west-3"

# Create infrastructure
/aws-docusaurus infra

# Deploy
/aws-docusaurus deploy
```

---

## Support

- **Issues**: [GitHub Issues](https://github.com/yaccp/claude-plugin-aws-docusaurus/issues)
- **Documentation**: [README.md](README.md)
- **Architecture**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
