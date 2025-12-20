# Changelog

All notable changes to AWS Docusaurus will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.8] - 2024-12-20

### Added

- **New command** `/yaccp-aws-docusaurus:destroy-infra`
  - Destroy all AWS infrastructure created by `/yaccp-aws-docusaurus:infra`
  - Ordered deletion respecting AWS dependencies
  - Double confirmation for safety
  - Handles Route53, CloudFront, S3, ACM, Lambda@Edge, and OAI cleanup
  - Graceful handling of Lambda@Edge replica propagation delays

---

## [1.1.5] - 2024-12-20

### Breaking Changes

- **Plugin renamed** from `aws-docusaurus` to `yaccp-aws-docusaurus`
  - Commands now use `/yaccp-aws-docusaurus:*` prefix
  - See [Migration Guide](#from-110-to-115) below

### Changed

- Updated plugin name for marketplace consistency
- Configuration path updated to `.claude/yaccp/aws-docusaurus/`

---

## [1.1.0] - 2024-12-20

### Changed

- **Renamed** StaticForge to AWS Docusaurus
- **Migrated** to Yaccp marketplace
- **Restructured** plugin to standard Claude Code format
- **Converted** SVG diagrams to Mermaid format (.mmd)

### Added

- **Maintenance Agents** (.claude/agents/)
  - `plugin-validator` - Validate plugin structure
  - `test-runner` - Execute validation tests
  - `doc-generator` - Generate documentation
  - `release-manager` - Manage releases
  - `changelog-updater` - Maintain changelog
  - `template-auditor` - Audit AWS templates
  - `security-reviewer` - Security audits
  - `pr-reviewer` - Pull request reviews
  - `dependency-checker` - Monitor dependencies

- **Mermaid Diagrams**
  - `architecture.mmd` - AWS architecture diagram
  - `workflow.mmd` - Init → Infra → Deploy flow
  - `cache-strategy.mmd` - Cache TTL by file type
  - `deploy-sequence.mmd` - Deployment sequence

### Removed

- `install.sh` - No longer needed with marketplace
- Old `.claude/` directory structure
- `CLAUDE.md` - Replaced by plugin structure
- SVG diagram files (replaced by Mermaid)

---

## [1.0.0] - 2024-12-19

### Added

- **Commands**
  - `/aws-docusaurus init` - Initialize Docusaurus projects pre-configured for AWS
  - `/aws-docusaurus infra` - Create complete AWS infrastructure (S3, CloudFront, ACM, Route53)
  - `/aws-docusaurus deploy` - Build and deploy with optimized caching
  - `/aws-docusaurus status` - Check infrastructure and deployment status

- **Features**
  - S3 bucket with private access (OAI only)
  - CloudFront CDN with global edge distribution
  - Automatic ACM certificate provisioning and validation
  - Route53 DNS alias configuration
  - Optional Lambda@Edge Basic Authentication
  - Optimized cache headers per file type
  - SPA support with custom error pages

- **Documentation**
  - Comprehensive README with quick start guide
  - Architecture documentation with diagrams
  - Contributing guidelines
  - CI/CD integration examples (GitHub Actions, GitLab CI)

- **Templates**
  - CloudFront distribution configuration
  - S3 bucket policy for OAI
  - Route53 alias record
  - Lambda@Edge Basic Auth function
  - IAM trust policy for Lambda

### Security

- All S3 public access blocked
- HTTPS enforced (HTTP redirect)
- TLS 1.2 minimum protocol
- OAI-only S3 access
- IAM least privilege for Lambda

### Supported Frameworks

- Docusaurus
- Next.js (static export)
- Vite / Vue / React
- Hugo
- Astro
- Gatsby

---

## [Unreleased]

### Planned

- CloudFront Functions support (lighter than Lambda@Edge)
- Multi-environment support (staging/production)
- Cost estimation command
- CloudWatch dashboard template
- Terraform/CDK export option

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| 1.1.8 | 2024-12-20 | New `/destroy-infra` command |
| 1.1.5 | 2024-12-20 | **Breaking:** Plugin renamed to `yaccp-aws-docusaurus` |
| 1.1.0 | 2024-12-20 | Yaccp marketplace, maintenance agents, Mermaid diagrams |
| 1.0.0 | 2024-12-19 | Initial release |

---

## Upgrade Guide

### From 1.1.0 to 1.1.5

**Breaking Change:** The plugin has been renamed from `aws-docusaurus` to `yaccp-aws-docusaurus`.

1. **Update your settings file** (`.claude/settings.local.json`):

   ```diff
   "enabledPlugins": {
   -  "aws-docusaurus@yaccp": true
   +  "yaccp-aws-docusaurus@yaccp": true
   }
   ```

2. **Update command references** in your scripts:

   ```diff
   - /aws-docusaurus init
   + /yaccp-aws-docusaurus:init

   - /aws-docusaurus infra
   + /yaccp-aws-docusaurus:infra

   - /aws-docusaurus deploy
   + /yaccp-aws-docusaurus:deploy

   - /aws-docusaurus status
   + /yaccp-aws-docusaurus:status
   ```

3. **Existing infrastructure is unaffected** - no AWS changes needed.

---

### From pre-release to 1.0.0

If you were using the development version:

1. Update the plugin:
   ```bash
   claude plugins update aws-docusaurus
   ```

2. Re-run infrastructure creation if needed:
   ```bash
   /aws-docusaurus infra
   ```

3. Deploy your site:
   ```bash
   /aws-docusaurus deploy
   ```
