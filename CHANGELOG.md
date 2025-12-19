# Changelog

All notable changes to StaticForge will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added

- **Commands**
  - `/staticforge init` - Initialize Docusaurus projects pre-configured for AWS
  - `/staticforge infra` - Create complete AWS infrastructure (S3, CloudFront, ACM, Route53)
  - `/staticforge deploy` - Build and deploy with optimized caching
  - `/staticforge status` - Check infrastructure and deployment status

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
| 1.0.0 | 2024-12-19 | Initial release |

---

## Upgrade Guide

### From pre-release to 1.0.0

If you were using the development version:

1. Update the plugin:
   ```bash
   claude plugins update staticforge
   ```

2. Re-run infrastructure creation if needed:
   ```bash
   /staticforge infra
   ```

3. Deploy your site:
   ```bash
   /staticforge deploy
   ```
