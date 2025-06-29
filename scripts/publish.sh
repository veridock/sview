#!/bin/bash
# Script to publish SView to various package registries

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

publish_project() {
    log_info "🚀 Publishing SView v${VERSION}..."
    
    # Ensure we have distribution packages
    if [ ! -f "${DIST_DIR}/${PROJECT_NAME}_${VERSION}_amd64.deb" ] || \
       [ ! -f "${DIST_DIR}/${PROJECT_NAME}_${VERSION}_linux_amd64.tar.gz" ]; then
        log_error "Distribution packages not found. Run 'make package' first."
        exit 1
    fi
    
    # Publish to crates.io (Rust)
    log_info "Publishing to crates.io..."
    if ! cargo publish; then
        log_warning "Failed to publish to crates.io. Continuing..."
    fi
    
    # Publish to npm (if GUI exists)
    if [ -d "${GUI_DIR}" ] && [ -f "${GUI_DIR}/package.json" ]; then
        log_info "Publishing to npm..."
        cd "${GUI_DIR}" && npm publish
    fi
    
    # Create GitHub release (if gh CLI is installed)
    if command -v gh &> /dev/null; then
        log_info "Creating GitHub release v${VERSION}..."
        gh release create "v${VERSION}" \
            "${DIST_DIR}/${PROJECT_NAME}_${VERSION}_amd64.deb" \
            "${DIST_DIR}/${PROJECT_NAME}_${VERSION}_linux_amd64.tar.gz" \
            --title "v${VERSION}" \
            --notes "Release v${VERSION}"
    else
        log_warning "GitHub CLI (gh) not found. Skipping GitHub release creation."
        log_info "To create a release manually, run:"
        echo "  gh release create v${VERSION} \\"
        echo "    ${DIST_DIR}/${PROJECT_NAME}_${VERSION}_amd64.deb \\"
        echo "    ${DIST_DIR}/${PROJECT_NAME}_${VERSION}_linux_amd64.tar.gz \\"
        echo "    --title \"v${VERSION}\" \\"
        echo "    --notes \"Release v${VERSION}\""
    fi
    
    log_success "✅ Published SView v${VERSION}"
}

# Main execution
publish_project
