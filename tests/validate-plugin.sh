#!/bin/bash
#
# validate-plugin.sh - Validate AWS Docusaurus plugin structure and content
#
# Usage: ./tests/validate-plugin.sh
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

PASSED=0
FAILED=0
WARNINGS=0

pass() { echo -e "${GREEN}✓${NC} $1"; ((PASSED++)); }
fail() { echo -e "${RED}✗${NC} $1"; ((FAILED++)); }
warn() { echo -e "${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }

echo ""
echo "=========================================="
echo "  AWS Docusaurus Plugin Validation"
echo "=========================================="
echo ""

# ===========================================
# 1. Structure Tests
# ===========================================
echo "1. Structure Tests"
echo "-------------------------------------------"

# Required files
REQUIRED_FILES=(
    ".claude-plugin/plugin.json"
    ".claude-plugin/marketplace.json"
    "README.md"
    "LICENSE"
    "CHANGELOG.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$PLUGIN_DIR/$file" ]]; then
        pass "$file exists"
    else
        fail "$file missing"
    fi
done

# Required directories
REQUIRED_DIRS=(
    "commands"
    "skills"
    "templates"
    "docs"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$PLUGIN_DIR/$dir" ]]; then
        pass "$dir/ directory exists"
    else
        fail "$dir/ directory missing"
    fi
done

echo ""

# ===========================================
# 2. Plugin.json Validation
# ===========================================
echo "2. Plugin.json Validation"
echo "-------------------------------------------"

PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

if command -v jq &> /dev/null; then
    # Validate JSON syntax
    if jq empty "$PLUGIN_JSON" 2>/dev/null; then
        pass "plugin.json is valid JSON"
    else
        fail "plugin.json has invalid JSON syntax"
    fi

    # Check required fields
    for field in name version description; do
        if jq -e ".$field" "$PLUGIN_JSON" > /dev/null 2>&1; then
            pass "plugin.json has '$field' field"
        else
            fail "plugin.json missing '$field' field"
        fi
    done

    # Check commands directory exists (commands field in plugin.json is optional)
    CMD_COUNT=$(find "$PLUGIN_DIR/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$CMD_COUNT" -gt 0 ]]; then
        pass "Found $CMD_COUNT command files in commands/"
    else
        fail "No command files found in commands/"
    fi

    # Check version format (semver)
    VERSION=$(jq -r '.version' "$PLUGIN_JSON")
    if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        pass "Version '$VERSION' follows semver"
    else
        warn "Version '$VERSION' may not follow semver"
    fi
else
    warn "jq not installed - skipping JSON validation"
fi

echo ""

# ===========================================
# 3. Commands Validation
# ===========================================
echo "3. Commands Validation"
echo "-------------------------------------------"

COMMANDS_DIR="$PLUGIN_DIR/commands"
COMMAND_FILES=(init.md infra.md deploy.md status.md)

for cmd in "${COMMAND_FILES[@]}"; do
    CMD_PATH="$COMMANDS_DIR/$cmd"
    if [[ -f "$CMD_PATH" ]]; then
        pass "commands/$cmd exists"

        # Check for required sections
        if grep -q "^# " "$CMD_PATH"; then
            pass "commands/$cmd has title"
        else
            fail "commands/$cmd missing title"
        fi

        # Check for environment variables section
        if grep -qi "environment\|variable\|export" "$CMD_PATH"; then
            pass "commands/$cmd documents environment variables"
        else
            warn "commands/$cmd may not document environment variables"
        fi

        # Check file is not empty
        LINES=$(wc -l < "$CMD_PATH")
        if [[ "$LINES" -gt 10 ]]; then
            pass "commands/$cmd has content ($LINES lines)"
        else
            warn "commands/$cmd seems short ($LINES lines)"
        fi
    else
        fail "commands/$cmd missing"
    fi
done

echo ""

# ===========================================
# 4. Templates Validation
# ===========================================
echo "4. Templates Validation"
echo "-------------------------------------------"

TEMPLATES_DIR="$PLUGIN_DIR/templates"

# Check JSON templates
for template in cloudfront-config.template.json s3-bucket-policy.template.json route53-alias.template.json; do
    TEMPLATE_PATH="$TEMPLATES_DIR/$template"
    if [[ -f "$TEMPLATE_PATH" ]]; then
        pass "templates/$template exists"

        if command -v jq &> /dev/null; then
            if jq empty "$TEMPLATE_PATH" 2>/dev/null; then
                pass "templates/$template is valid JSON"
            else
                fail "templates/$template has invalid JSON"
            fi
        fi
    else
        fail "templates/$template missing"
    fi
done

# Check Lambda function
LAMBDA_FILE="$TEMPLATES_DIR/lambda/basic-auth.template.js"
if [[ -f "$LAMBDA_FILE" ]]; then
    pass "templates/lambda/basic-auth.template.js exists"

    # Check for exports.handler
    if grep -q "exports.handler" "$LAMBDA_FILE"; then
        pass "Lambda has exports.handler"
    else
        fail "Lambda missing exports.handler"
    fi
else
    fail "templates/lambda/basic-auth.template.js missing"
fi

echo ""

# ===========================================
# 5. Documentation Validation
# ===========================================
echo "5. Documentation Validation"
echo "-------------------------------------------"

# Check README sections
README="$PLUGIN_DIR/README.md"
REQUIRED_SECTIONS=("Installation" "Features" "Commands" "Architecture")

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qi "## .*$section\|# .*$section" "$README"; then
        pass "README has '$section' section"
    else
        warn "README may be missing '$section' section"
    fi
done

# Check for diagrams
DIAGRAMS_DIR="$PLUGIN_DIR/docs/images"
DIAGRAM_COUNT=$(find "$DIAGRAMS_DIR" -name "*.mmd" 2>/dev/null | wc -l)
if [[ "$DIAGRAM_COUNT" -gt 0 ]]; then
    pass "Found $DIAGRAM_COUNT Mermaid diagrams"
else
    warn "No Mermaid diagrams found"
fi

# Check ARCHITECTURE.md
if [[ -f "$PLUGIN_DIR/docs/ARCHITECTURE.md" ]]; then
    pass "docs/ARCHITECTURE.md exists"
    ARCH_LINES=$(wc -l < "$PLUGIN_DIR/docs/ARCHITECTURE.md")
    if [[ "$ARCH_LINES" -gt 50 ]]; then
        pass "ARCHITECTURE.md has substantial content ($ARCH_LINES lines)"
    else
        warn "ARCHITECTURE.md seems short"
    fi
else
    fail "docs/ARCHITECTURE.md missing"
fi

echo ""

# ===========================================
# 6. License and Legal
# ===========================================
echo "6. License and Legal"
echo "-------------------------------------------"

if [[ -f "$PLUGIN_DIR/LICENSE" ]]; then
    pass "LICENSE file exists"

    if grep -qi "Apache" "$PLUGIN_DIR/LICENSE"; then
        pass "License is Apache 2.0"
    else
        warn "License type unclear"
    fi
else
    fail "LICENSE file missing"
fi

if grep -qi "license" "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null; then
    pass "plugin.json specifies license"
else
    warn "plugin.json should specify license"
fi

echo ""

# ===========================================
# Summary
# ===========================================
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [[ "$FAILED" -gt 0 ]]; then
    echo -e "${RED}Validation FAILED${NC}"
    exit 1
else
    if [[ "$WARNINGS" -gt 0 ]]; then
        echo -e "${YELLOW}Validation PASSED with warnings${NC}"
    else
        echo -e "${GREEN}Validation PASSED${NC}"
    fi
    exit 0
fi
