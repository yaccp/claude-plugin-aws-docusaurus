# Plugin Validator Agent

Validate the complete structure and content of the aws-docusaurus plugin.

## Validation Checklist

### 1. Structure Validation

Check that all required files and directories exist:

```
.claude-plugin/
├── plugin.json       # Required - Plugin configuration
└── marketplace.json  # Required - Marketplace metadata

commands/
├── init.md          # Required - /aws-docusaurus init
├── infra.md         # Required - /aws-docusaurus infra
├── deploy.md        # Required - /aws-docusaurus deploy
└── status.md        # Required - /aws-docusaurus status

skills/
└── aws-docusaurus.md  # Required - Main skill

templates/
├── cloudfront-config.template.json
├── s3-bucket-policy.template.json
├── route53-alias.template.json
├── deploy.template.sh
└── lambda/
    ├── basic-auth.template.js
    └── trust-policy.json

docs/
├── ARCHITECTURE.md
└── CONTRIBUTING.md

README.md            # Required
LICENSE              # Required
CHANGELOG.md         # Required
INSTALLATION.md      # Required
```

### 2. JSON Validation

For each JSON file, verify:
- Valid JSON syntax
- Required fields present
- No duplicate keys
- Proper escaping

#### plugin.json Required Fields
- `name` (string, lowercase, no spaces)
- `version` (semver format: x.y.z)
- `description` (non-empty string)
- `author` (string)
- `license` (string)
- `commands` (array with at least one command)

#### marketplace.json Required Fields
- `name` (string)
- `owner.name` (string)
- `owner.url` (valid URL)
- `plugins` (array with at least one plugin)

### 3. Command Validation

For each command in `commands/`:
- Must have a title (# heading)
- Must document required environment variables
- Must have usage examples
- Must have error handling section

### 4. Template Validation

For each template:
- Valid syntax (JSON/JS/Shell)
- All placeholders documented ({{VARIABLE}})
- No hardcoded secrets or credentials

### 5. Documentation Validation

- README.md has all required sections:
  - Features
  - Installation
  - Quick Start
  - Commands
  - Architecture
  - Environment Variables
  - License

- CHANGELOG.md follows Keep a Changelog format
- All internal links are valid

## Execution

Run the validation script:
```bash
./tests/validate-plugin.sh
```

Report any issues found with:
- File path
- Issue description
- Suggested fix

## Output Format

```
Plugin Validation Report
========================

Structure: ✓ PASS / ✗ FAIL
  - [status] file/directory

JSON Files: ✓ PASS / ✗ FAIL
  - [status] file: issue

Commands: ✓ PASS / ✗ FAIL
  - [status] command: issue

Templates: ✓ PASS / ✗ FAIL
  - [status] template: issue

Documentation: ✓ PASS / ✗ FAIL
  - [status] doc: issue

Overall: ✓ PASS / ✗ FAIL (X issues found)
```
