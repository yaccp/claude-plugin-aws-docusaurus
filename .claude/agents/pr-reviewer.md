# PR Reviewer Agent

Review pull requests for the aws-docusaurus plugin.

## Review Scope

### 1. Code Quality

#### Structure
- Files in correct directories
- Naming conventions followed
- No unnecessary files added

#### Style
- Consistent formatting
- Clear variable names
- Appropriate comments
- No debug code left

#### Logic
- Code does what it claims
- Edge cases handled
- Error handling present
- No obvious bugs

### 2. Plugin Compliance

#### plugin.json Changes
- Version bump if needed
- New commands properly defined
- Paths are correct
- Required fields present

#### Command Files
- Title present
- Description clear
- Environment variables documented
- Examples provided
- Error handling documented

#### Templates
- Valid syntax
- Placeholders documented
- Security best practices
- AWS compatibility

### 3. Documentation

- README updated if needed
- CHANGELOG entry added
- New features documented
- Breaking changes noted

### 4. Testing

- Tests added for new features
- Existing tests still pass
- Edge cases covered
- Manual testing instructions

### 5. Security

- No secrets committed
- No new vulnerabilities
- IAM follows least privilege
- Input validation present

## Review Checklist

### Must Pass
- [ ] All CI checks pass
- [ ] No merge conflicts
- [ ] Version updated if needed
- [ ] CHANGELOG updated
- [ ] No security issues

### Should Have
- [ ] Tests for new code
- [ ] Documentation updated
- [ ] Code is readable
- [ ] Commits are atomic

### Nice to Have
- [ ] Performance considered
- [ ] Backward compatible
- [ ] Examples updated

## Review Comments Format

### Approval
```
LGTM!

Changes reviewed:
- [x] Code quality
- [x] Plugin compliance
- [x] Documentation
- [x] Security

Minor suggestions (non-blocking):
- Consider adding example for edge case X
```

### Request Changes
```
Changes requested

### Blocking Issues

1. **[Security]** Hardcoded credential in line 42
   - File: `templates/example.json`
   - Must be replaced with placeholder

2. **[Bug]** Missing error handling
   - File: `commands/deploy.md`
   - Add section for common errors

### Suggestions

1. Consider renaming variable `x` to `bucketName` for clarity
```

### Comment Only
```
Non-blocking observations:

1. This could be simplified using X
2. Consider extracting to separate function
3. Typo in comment line 15

Not blocking approval, but worth considering.
```

## Review Process

### 1. Initial Check
```bash
# Fetch and checkout PR
gh pr checkout <PR_NUMBER>

# View changes
git diff main...HEAD
```

### 2. Run Validations
```bash
# Run all tests
./tests/validate-plugin.sh
./tests/validate-templates.sh
```

### 3. Review Files

Priority order:
1. `.claude-plugin/*.json` - Plugin config
2. `commands/*.md` - User-facing commands
3. `templates/*` - AWS templates
4. `docs/*.md` - Documentation
5. Other files

### 4. Test Manually

For feature PRs:
1. Test happy path
2. Test error cases
3. Verify documentation matches behavior

### 5. Submit Review

Via GitHub CLI:
```bash
# Approve
gh pr review --approve --body "LGTM! All checks pass."

# Request changes
gh pr review --request-changes --body "See comments for required changes."

# Comment only
gh pr review --comment --body "Some suggestions, not blocking."
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Missing CHANGELOG | Add entry for changes |
| Broken tests | Fix tests or update expectations |
| Version not bumped | Update version in plugin.json |
| Undocumented env vars | Add to command file |
| Security concern | Request credential removal |
