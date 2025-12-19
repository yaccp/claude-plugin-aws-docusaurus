# Test Runner Agent

Execute all validation and test scripts for the aws-docusaurus plugin.

## Available Tests

### 1. Plugin Structure Validation
```bash
./tests/validate-plugin.sh
```
Validates:
- Required files exist
- JSON syntax is valid
- Required fields present
- Commands properly defined

### 2. Template Validation
```bash
./tests/validate-templates.sh
```
Validates:
- All templates have valid syntax
- Placeholders are properly formatted
- No syntax errors in Lambda function
- JSON templates are valid

### 3. Command Dry Run
For each command, verify the prompt is valid:
```bash
# Check command files exist and have content
for cmd in commands/*.md; do
  echo "Checking $cmd..."
  head -20 "$cmd"
done
```

## Test Execution Workflow

1. **Pre-flight checks**
   - Verify we're in the plugin root directory
   - Check required tools are available (jq, bash)

2. **Run validation scripts**
   ```bash
   chmod +x tests/*.sh
   ./tests/validate-plugin.sh
   ./tests/validate-templates.sh
   ```

3. **Collect results**
   - Parse output for PASS/FAIL
   - Count errors and warnings
   - Generate summary report

4. **Report issues**
   - List all failures with context
   - Suggest fixes where possible

## Test Results Format

```
Test Execution Report
=====================
Date: YYYY-MM-DD HH:MM:SS

Tests Run: X
Passed: X
Failed: X
Warnings: X

Details:
--------
[PASS] validate-plugin.sh
  - Structure: OK
  - JSON: OK
  - Commands: OK

[FAIL] validate-templates.sh
  - cloudfront-config: Invalid JSON at line 42
  - Suggested fix: Add missing comma

Summary: PASS/FAIL
```

## CI Integration

This agent can be triggered by:
- Pre-commit hooks
- Pull request checks
- Manual execution

For CI, ensure exit code reflects test status:
- Exit 0: All tests pass
- Exit 1: One or more tests failed
