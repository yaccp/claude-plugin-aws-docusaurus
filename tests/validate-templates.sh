#!/bin/bash
#
# validate-templates.sh - Validate AWS templates
#

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(dirname "$SCRIPT_DIR")/templates"

PASSED=0
FAILED=0

pass() { echo -e "${GREEN}✓${NC} $1"; ((PASSED++)); }
fail() { echo -e "${RED}✗${NC} $1"; ((FAILED++)); }

echo ""
echo "AWS Templates Validation"
echo "========================"
echo ""

# Check jq is available
if ! command -v jq &> /dev/null; then
    echo "jq is required for template validation"
    exit 1
fi

# ===========================================
# CloudFront Config Template
# ===========================================
echo "CloudFront Config Template"
echo "--------------------------"

CF_TEMPLATE="$TEMPLATES_DIR/cloudfront-config.template.json"

if jq empty "$CF_TEMPLATE" 2>/dev/null; then
    pass "Valid JSON syntax"
else
    fail "Invalid JSON syntax"
fi

# Check required CloudFront fields
CF_FIELDS=(CallerReference Origins DefaultCacheBehavior Enabled)
for field in "${CF_FIELDS[@]}"; do
    if jq -e ".$field" "$CF_TEMPLATE" > /dev/null 2>&1; then
        pass "Has '$field' field"
    else
        fail "Missing '$field' field"
    fi
done

# Check HTTPS redirect
if jq -e '.DefaultCacheBehavior.ViewerProtocolPolicy' "$CF_TEMPLATE" | grep -q "redirect-to-https"; then
    pass "HTTPS redirect configured"
else
    fail "HTTPS redirect not configured"
fi

echo ""

# ===========================================
# S3 Bucket Policy Template
# ===========================================
echo "S3 Bucket Policy Template"
echo "-------------------------"

S3_TEMPLATE="$TEMPLATES_DIR/s3-bucket-policy.template.json"

if jq empty "$S3_TEMPLATE" 2>/dev/null; then
    pass "Valid JSON syntax"
else
    fail "Invalid JSON syntax"
fi

# Check IAM policy structure
if jq -e '.Version' "$S3_TEMPLATE" > /dev/null 2>&1; then
    pass "Has 'Version' field"
else
    fail "Missing 'Version' field"
fi

if jq -e '.Statement' "$S3_TEMPLATE" > /dev/null 2>&1; then
    pass "Has 'Statement' field"
else
    fail "Missing 'Statement' field"
fi

# Check for s3:GetObject action
if jq -r '.Statement[].Action' "$S3_TEMPLATE" | grep -q "s3:GetObject"; then
    pass "Allows s3:GetObject"
else
    fail "Missing s3:GetObject permission"
fi

echo ""

# ===========================================
# Route53 Alias Template
# ===========================================
echo "Route53 Alias Template"
echo "----------------------"

R53_TEMPLATE="$TEMPLATES_DIR/route53-alias.template.json"

if jq empty "$R53_TEMPLATE" 2>/dev/null; then
    pass "Valid JSON syntax"
else
    fail "Invalid JSON syntax"
fi

# Check Changes structure
if jq -e '.Changes' "$R53_TEMPLATE" > /dev/null 2>&1; then
    pass "Has 'Changes' field"
else
    fail "Missing 'Changes' field"
fi

# Check for AliasTarget
if jq -r '.. | .AliasTarget? | select(.)' "$R53_TEMPLATE" | grep -q "HostedZoneId"; then
    pass "Has AliasTarget configuration"
else
    fail "Missing AliasTarget configuration"
fi

echo ""

# ===========================================
# Lambda Trust Policy
# ===========================================
echo "Lambda Trust Policy"
echo "-------------------"

TRUST_POLICY="$TEMPLATES_DIR/lambda/trust-policy.json"

if jq empty "$TRUST_POLICY" 2>/dev/null; then
    pass "Valid JSON syntax"
else
    fail "Invalid JSON syntax"
fi

# Check for Lambda service
if jq -r '.. | .Service? | select(.)' "$TRUST_POLICY" | grep -q "lambda.amazonaws.com"; then
    pass "Trusts lambda.amazonaws.com"
else
    fail "Missing lambda.amazonaws.com trust"
fi

# Check for Edge Lambda service
if jq -r '.. | .Service? | select(.)' "$TRUST_POLICY" | grep -q "edgelambda.amazonaws.com"; then
    pass "Trusts edgelambda.amazonaws.com"
else
    fail "Missing edgelambda.amazonaws.com trust"
fi

echo ""

# ===========================================
# Lambda Basic Auth Function
# ===========================================
echo "Lambda Basic Auth Function"
echo "--------------------------"

LAMBDA_FILE="$TEMPLATES_DIR/lambda/basic-auth.template.js"

if [[ -f "$LAMBDA_FILE" ]]; then
    pass "File exists"

    # Check for handler export
    if grep -q "exports.handler" "$LAMBDA_FILE"; then
        pass "Has exports.handler"
    else
        fail "Missing exports.handler"
    fi

    # Check for callback usage (Lambda@Edge pattern)
    if grep -q "callback" "$LAMBDA_FILE"; then
        pass "Uses callback pattern"
    else
        fail "Missing callback pattern"
    fi

    # Check for 401 response
    if grep -q "401" "$LAMBDA_FILE"; then
        pass "Returns 401 for unauthorized"
    else
        fail "Missing 401 response"
    fi

    # Check for WWW-Authenticate header
    if grep -qi "www-authenticate" "$LAMBDA_FILE"; then
        pass "Sets WWW-Authenticate header"
    else
        fail "Missing WWW-Authenticate header"
    fi

    # Check for Basic auth
    if grep -q "Basic" "$LAMBDA_FILE"; then
        pass "Uses Basic authentication"
    else
        fail "Missing Basic authentication"
    fi
else
    fail "File missing"
fi

echo ""

# ===========================================
# Summary
# ===========================================
echo "========================"
echo "Summary"
echo "========================"
echo ""
echo -e "  ${GREEN}Passed:${NC} $PASSED"
echo -e "  ${RED}Failed:${NC} $FAILED"
echo ""

if [[ "$FAILED" -gt 0 ]]; then
    echo -e "${RED}Template validation FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Template validation PASSED${NC}"
    exit 0
fi
