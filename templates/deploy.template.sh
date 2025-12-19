#!/bin/bash
#
# Static Site Deployment Script Template
#
# This script deploys a static site to AWS S3 + CloudFront with optimized caching.
#
# Usage:
#   1. Copy this file to your project root
#   2. Replace placeholder values below
#   3. Make executable: chmod +x deploy.sh
#   4. Run: ./deploy.sh
#
# Prerequisites:
#   - AWS CLI installed and configured
#   - Infrastructure created with aws-static-site-infra agent
#   - Static site generator (npm, etc.) installed

set -e  # Exit on error

#==============================================================================
# CONFIGURATION - Replace these values
#==============================================================================

# AWS Configuration
export AWS_PROFILE="${AWS_PROFILE:-default}"
export AWS_REGION="${AWS_REGION:-eu-west-3}"

# Infrastructure IDs (from aws-static-site-infra output)
S3_BUCKET="${S3_BUCKET:-your-bucket-name}"
CLOUDFRONT_DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:-E1234567890ABC}"

# Build Configuration
BUILD_COMMAND="${BUILD_COMMAND:-npm run build}"
BUILD_DIR="${BUILD_DIR:-build}"

# Site URL (optional, for verification)
SITE_URL="${SITE_URL:-https://your-site.example.com}"

#==============================================================================
# SCRIPT - No changes needed below
#==============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "========================================"
echo "  AWS Static Site Deployment"
echo "========================================"
echo -e "${NC}"
echo "S3 Bucket: ${S3_BUCKET}"
echo "CloudFront: ${CLOUDFRONT_DISTRIBUTION_ID}"
echo "Build Dir: ${BUILD_DIR}"
echo "Region: ${AWS_REGION}"
echo "========================================"
echo ""

# Validate configuration
if [[ "${S3_BUCKET}" == "your-bucket-name" ]]; then
    echo -e "${RED}ERROR: S3_BUCKET not configured. Edit this script.${NC}"
    exit 1
fi

if [[ "${CLOUDFRONT_DISTRIBUTION_ID}" == "E1234567890ABC" ]]; then
    echo -e "${RED}ERROR: CLOUDFRONT_DISTRIBUTION_ID not configured. Edit this script.${NC}"
    exit 1
fi

#------------------------------------------------------------------------------
# Step 1: Build the site
#------------------------------------------------------------------------------
echo -e "${YELLOW}[1/5] Building site...${NC}"
echo "Running: ${BUILD_COMMAND}"
${BUILD_COMMAND}

if [ ! -d "${BUILD_DIR}" ]; then
    echo -e "${RED}ERROR: Build directory '${BUILD_DIR}' not found!${NC}"
    echo "Check BUILD_COMMAND and BUILD_DIR settings."
    exit 1
fi

BUILD_SIZE=$(du -sh ${BUILD_DIR} | cut -f1)
echo -e "${GREEN}Build complete: ${BUILD_SIZE}${NC}"
echo ""

#------------------------------------------------------------------------------
# Step 2: Upload static assets (immutable, 1-year cache)
#------------------------------------------------------------------------------
echo -e "${YELLOW}[2/5] Uploading static assets (1-year cache)...${NC}"
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
    --delete \
    --cache-control "public, max-age=31536000, immutable" \
    --exclude "*.html" \
    --exclude "*.htm" \
    --exclude "sw.js" \
    --exclude "service-worker.js" \
    --exclude "sitemap.xml" \
    --exclude "robots.txt" \
    --exclude "page-data/*" \
    --exclude "*.json" \
    --exclude "_next/data/*"

echo -e "${GREEN}Static assets uploaded.${NC}"
echo ""

#------------------------------------------------------------------------------
# Step 3: Upload HTML files (no cache)
#------------------------------------------------------------------------------
echo -e "${YELLOW}[3/5] Uploading HTML files (no cache)...${NC}"
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
    --exclude "*" \
    --include "*.html" \
    --include "*.htm" \
    --cache-control "public, max-age=0, must-revalidate" \
    --content-type "text/html; charset=utf-8"

echo -e "${GREEN}HTML files uploaded.${NC}"
echo ""

#------------------------------------------------------------------------------
# Step 4: Upload special files
#------------------------------------------------------------------------------
echo -e "${YELLOW}[4/5] Uploading special files...${NC}"

# Service Worker (no cache - must always be fresh)
for SW_FILE in sw.js service-worker.js; do
    if [ -f "${BUILD_DIR}/${SW_FILE}" ]; then
        aws s3 cp ${BUILD_DIR}/${SW_FILE} s3://${S3_BUCKET}/${SW_FILE} \
            --cache-control "public, max-age=0, must-revalidate" \
            --content-type "application/javascript"
        echo "  - ${SW_FILE}"
    fi
done

# JSON files (page data, manifests - short cache)
aws s3 sync ${BUILD_DIR}/ s3://${S3_BUCKET}/ \
    --exclude "*" \
    --include "*.json" \
    --include "page-data/*" \
    --include "_next/data/*" \
    --cache-control "public, max-age=0, must-revalidate" \
    --content-type "application/json" \
    2>/dev/null || true

# SEO files (1-day cache)
for SEO_FILE in sitemap.xml robots.txt; do
    if [ -f "${BUILD_DIR}/${SEO_FILE}" ]; then
        aws s3 cp ${BUILD_DIR}/${SEO_FILE} s3://${S3_BUCKET}/${SEO_FILE} \
            --cache-control "public, max-age=86400"
        echo "  - ${SEO_FILE}"
    fi
done

echo -e "${GREEN}Special files uploaded.${NC}"
echo ""

#------------------------------------------------------------------------------
# Step 5: Invalidate CloudFront cache
#------------------------------------------------------------------------------
echo -e "${YELLOW}[5/5] Invalidating CloudFront cache...${NC}"
INVALIDATION_RESULT=$(aws cloudfront create-invalidation \
    --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
    --paths "/*" \
    --output json)

INVALIDATION_ID=$(echo $INVALIDATION_RESULT | jq -r '.Invalidation.Id')
INVALIDATION_STATUS=$(echo $INVALIDATION_RESULT | jq -r '.Invalidation.Status')

echo "Invalidation ID: ${INVALIDATION_ID}"
echo "Status: ${INVALIDATION_STATUS}"
echo ""

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------
echo -e "${GREEN}"
echo "========================================"
echo "  Deployment Complete!"
echo "========================================"
echo -e "${NC}"
echo "Site URL: ${SITE_URL}"
echo ""
echo "Cache invalidation typically takes 1-5 minutes."
echo ""
echo "Check invalidation status:"
echo "  aws cloudfront get-invalidation \\"
echo "    --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \\"
echo "    --id ${INVALIDATION_ID}"
echo ""
echo "Verify deployment:"
echo "  curl -I ${SITE_URL}"
echo ""
