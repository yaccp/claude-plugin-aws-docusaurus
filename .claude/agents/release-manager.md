# Release Manager Agent

Manage version releases for the aws-docusaurus plugin.

## Release Process

### 1. Pre-Release Checks

Before creating a release:

```bash
# Run all validations
./tests/validate-plugin.sh
./tests/validate-templates.sh

# Check git status
git status
git diff --stat main

# Verify no uncommitted changes
```

### 2. Version Bump

Update version in all files:

| File | Field |
|------|-------|
| `.claude-plugin/plugin.json` | `version` |
| `.claude-plugin/marketplace.json` | `metadata.version` and `plugins[0].version` |
| `CHANGELOG.md` | Add new version section |

#### Semantic Versioning

- **MAJOR** (x.0.0): Breaking changes
- **MINOR** (0.x.0): New features, backward compatible
- **PATCH** (0.0.x): Bug fixes, backward compatible

### 3. Changelog Update

Add entry to CHANGELOG.md:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Modified behavior description

### Fixed
- Bug fix description
```

### 4. Git Tag

```bash
# Create annotated tag
git tag -a vX.Y.Z -m "Release vX.Y.Z: Brief description"

# Push tag
git push origin vX.Y.Z
```

### 5. GitHub Release

Create GitHub release with:
- Tag: vX.Y.Z
- Title: vX.Y.Z - Release Name
- Body: Copy from CHANGELOG.md
- Assets: None (plugin is the repo itself)

```bash
gh release create vX.Y.Z \
  --title "vX.Y.Z - Release Title" \
  --notes-file release-notes.md
```

## Release Checklist

- [ ] All tests pass
- [ ] Version bumped in all files
- [ ] CHANGELOG.md updated
- [ ] README.md version references updated
- [ ] No uncommitted changes
- [ ] Branch is up to date with main
- [ ] Git tag created
- [ ] GitHub release created

## Rollback Procedure

If a release has issues:

```bash
# Delete remote tag
git push origin --delete vX.Y.Z

# Delete local tag
git tag -d vX.Y.Z

# Delete GitHub release
gh release delete vX.Y.Z --yes

# Revert commits if needed
git revert HEAD
```

## Version History

Track releases:

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2024-XX-XX | Initial release |

## Automation

For automated releases via CI:

```yaml
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
```
