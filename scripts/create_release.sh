#!/bin/bash
# Script to create a release build of SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "🚀 Creating release build..."

# Ensure dist directory exists
mkdir -p "${DIST_DIR}"

# Copy release binary
cp "${TARGET_DIR}/release/${PROJECT_NAME}" "${DIST_DIR}/"

# Copy GUI binary if it exists
if [ -f "${TARGET_DIR}/release/${PROJECT_NAME}-gui" ]; then
    cp "${TARGET_DIR}/release/${PROJECT_NAME}-gui" "${DIST_DIR}/"
fi

# Copy documentation
cp "${PROJECT_ROOT}/README.md" "${DIST_DIR}/"
cp "${PROJECT_ROOT}/LICENSE" "${DIST_DIR}/"

log_success "✅ Release build completed"
echo "📦 Distribution files in ${DIST_DIR}/"
echo ""
