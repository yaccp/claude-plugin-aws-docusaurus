# Contributing to AWS Docusaurus

Thank you for your interest in contributing to AWS Docusaurus! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful, inclusive, and constructive in all interactions.

## How to Contribute

### Reporting Bugs

1. Check existing issues to avoid duplicates
2. Use the bug report template
3. Include:
   - AWS Docusaurus version
   - Claude Code version
   - AWS region
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages/logs

### Suggesting Features

1. Check existing feature requests
2. Describe the use case
3. Explain why it benefits other users
4. Provide examples if possible

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

## Development Setup

### Prerequisites

- Claude Code CLI installed
- AWS CLI configured
- Node.js >= 20
- Git

### Local Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/aws-docusaurus.git
cd aws-docusaurus

# Test the plugin locally
claude plugins add-local ./plugin/aws-docusaurus

# Make changes and test
claude
> /aws-docusaurus init
```

### Testing Changes

```bash
# Test each command
export PROJECT_NAME="test-project"
export SITE_TITLE="Test Site"
export SITE_URL="https://test.example.com"

# Run init command
> /aws-docusaurus init

# Verify output
ls -la test-project/
```

## Project Structure

```
aws-docusaurus/
├── plugin.json           # Plugin manifest
├── README.md             # Main documentation
├── LICENSE               # MIT License
├── commands/             # Slash commands
│   ├── init.md          # /aws-docusaurus init
│   ├── infra.md         # /aws-docusaurus infra
│   ├── deploy.md        # /aws-docusaurus deploy
│   └── status.md        # /aws-docusaurus status
├── skills/              # Skills
│   └── aws-docusaurus.md   # Main skill
├── templates/           # AWS templates
│   ├── cloudfront-config.template.json
│   ├── s3-bucket-policy.template.json
│   └── lambda/
│       └── basic-auth.template.js
└── docs/                # Documentation
    ├── ARCHITECTURE.md
    ├── CONTRIBUTING.md
    └── images/
```

## Coding Standards

### Markdown Files

- Use ATX-style headers (`#`, `##`, `###`)
- Include code blocks with language specifiers
- Use tables for structured data
- Keep lines under 100 characters when possible

### Command Files

- Clear description at the top
- Document all environment variables
- Include step-by-step instructions
- Provide verification commands
- Add troubleshooting section

### Templates

- Use JSON with proper indentation
- Include comments for complex configurations
- Validate JSON syntax before committing

## Commit Messages

Follow conventional commits:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(commands): add status command for health checks
fix(infra): correct S3 bucket policy for OAI
docs(readme): update installation instructions
```

## Release Process

1. Update version in `plugin.json`
2. Update `CHANGELOG.md`
3. Create git tag (`git tag v1.0.1`)
4. Push tag (`git push origin v1.0.1`)
5. Create GitHub release

## Documentation

When adding features:

1. Update relevant command documentation
2. Update README if needed
3. Add to CHANGELOG
4. Include diagrams for complex features (Mermaid)

## Testing Checklist

Before submitting a PR:

- [ ] All commands execute without errors
- [ ] Documentation is updated
- [ ] No sensitive data in commits
- [ ] CHANGELOG updated
- [ ] Works with latest Claude Code version

## Getting Help

- Open an issue for questions
- Check existing documentation
- Review closed issues for solutions

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- README.md contributors section
- GitHub contributors page

Thank you for contributing to AWS Docusaurus!
