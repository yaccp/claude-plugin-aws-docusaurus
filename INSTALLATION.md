# Installation Guide

## Method 1: GitHub Marketplace (Recommended)

### Step 1: Add the marketplace

```bash
/plugin marketplace add cferaudet/staticforge
```

### Step 2: Install the plugin

```bash
/plugin install staticforge
```

### Step 3: Verify installation

```bash
/help
```

You should see the StaticForge commands:
- `/staticforge init`
- `/staticforge infra`
- `/staticforge deploy`
- `/staticforge status`

---

## Method 2: Local Installation (Development)

### Clone and install locally

```bash
# Clone the repository
git clone https://github.com/cferaudet/staticforge.git

# Add as local plugin
/plugin add-local ./staticforge
```

---

## Method 3: Direct from GitHub URL

```bash
/plugin install github:cferaudet/staticforge
```

---

## Updating the Plugin

```bash
# Check for updates
/plugin list

# Update to latest version
/plugin update staticforge
```

---

## Uninstalling

```bash
/plugin uninstall staticforge
```

---

## Troubleshooting

### Plugin not found

Ensure you've added the marketplace first:
```bash
/plugin marketplace add cferaudet/staticforge
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
/staticforge init

# Set AWS variables
export SITE_NAME="my-docs"
export DOMAIN="docs.example.com"
export HOSTED_ZONE_ID="Z1234567890ABC"
export AWS_PROFILE="default"
export AWS_REGION="eu-west-3"

# Create infrastructure
/staticforge infra

# Deploy
/staticforge deploy
```

---

## Support

- **Issues**: [GitHub Issues](https://github.com/cferaudet/staticforge/issues)
- **Documentation**: [README.md](README.md)
- **Architecture**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
