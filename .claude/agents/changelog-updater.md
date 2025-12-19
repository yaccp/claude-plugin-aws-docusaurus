# Changelog Updater Agent

Maintain the CHANGELOG.md following Keep a Changelog format.

## Changelog Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security fixes

## [1.0.0] - YYYY-MM-DD

### Added
- Initial release features
```

## Update Workflow

### 1. Analyze Changes

Review git history since last release:

```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Get changed files
git diff --name-only $(git describe --tags --abbrev=0)..HEAD
```

### 2. Categorize Changes

Map commits to changelog categories:

| Commit Prefix | Category |
|---------------|----------|
| `feat:` | Added |
| `fix:` | Fixed |
| `docs:` | Changed (Documentation) |
| `refactor:` | Changed |
| `perf:` | Changed (Performance) |
| `test:` | Changed (Testing) |
| `chore:` | Changed (Maintenance) |
| `security:` | Security |
| `deprecate:` | Deprecated |
| `remove:` | Removed |

### 3. Write Entries

For each change, write a clear entry:

**Good:**
```markdown
### Added
- Basic authentication support via Lambda@Edge for staging sites
```

**Bad:**
```markdown
### Added
- Added auth
```

### 4. Update Links

At the bottom of CHANGELOG.md, update comparison links:

```markdown
[Unreleased]: https://github.com/yaccp/claude-plugin-aws-docusaurus/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yaccp/claude-plugin-aws-docusaurus/releases/tag/v1.0.0
```

## Entry Guidelines

### Do
- Write in present tense ("Add" not "Added")
- Be specific about what changed
- Link to issues/PRs when relevant
- Group related changes

### Don't
- Include internal/technical details users don't care about
- Use commit messages verbatim
- Include trivial changes (typo fixes)
- Duplicate entries

## Automation Triggers

Update changelog when:
- PR is merged to main
- New feature branch is created
- Release is prepared

## Example Session

```
User: Update changelog for new cache invalidation feature

Agent:
1. Reading current CHANGELOG.md
2. Checking [Unreleased] section
3. Adding entry under "Added":
   - CloudFront cache invalidation patterns for selective cache clearing
4. Updated CHANGELOG.md
```
