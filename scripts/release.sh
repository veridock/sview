#!/bin/bash
# Script to create a release build of SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

create_release() {
    log_info "🚀 Creating release build..."
    
    # Clean previous builds
    "${SCRIPTS_DIR}/clean.sh"
    
    # Build CLI
    if ! "${SCRIPTS_DIR}/build_cli.sh"; then
        log_error "Failed to build CLI"
        exit 1
    fi
    
    # Build GUI if it exists
    if [ -d "${GUI_DIR}" ]; then
        if ! "${SCRIPTS_DIR}/build_gui.sh"; then
            log_warning "GUI build failed, continuing with CLI only"
        fi
    fi
    
    # Create distribution directory
    mkdir -p "${DIST_DIR}"
    
    # Copy binaries and assets
    log_info "Preparing distribution package..."
    
    # Copy CLI binary
    cp "${TARGET_DIR}/release/${PROJECT_NAME}" "${DIST_DIR}/"
    
    # Copy GUI assets if they exist
    if [ -d "${GUI_DIR}/dist" ]; then
        cp -r "${GUI_DIR}/dist" "${DIST_DIR}/gui"
    fi
    
    # Create a version file
    echo "${PROJECT_NAME} ${VERSION}" > "${DIST_DIR}/VERSION"
    date >> "${DIST_DIR}/VERSION"
    
    # Create a tarball
    tar -czf "${DIST_DIR}/${PROJECT_NAME}-${VERSION}.tar.gz" -C "${DIST_DIR}" .
    
    log_success "✅ Release created in ${DIST_DIR}"
    log_info "Release tarball: ${DIST_DIR}/${PROJECT_NAME}-${VERSION}.tar.gz"
}

# Main execution
create_release
