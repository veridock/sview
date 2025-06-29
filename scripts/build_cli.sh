#!/bin/bash
# Script to build the SView CLI

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "🔨 Building CLI..."
log_info "Using RUSTFLAGS: ${RUSTFLAGS}"

# Build the project
log_info "Building with: RUSTFLAGS=${RUSTFLAGS} cargo build ${CARGO_FLAGS}"
if RUSTFLAGS="${RUSTFLAGS}" cargo build ${CARGO_FLAGS}; then
    BINARY_PATH="${TARGET_DIR}/release/${PROJECT_NAME}"
    log_success "CLI build completed"
    log_info "Binary location: ${BINARY_PATH}"
    
    # Display binary size
    if command -v du >/dev/null; then
        BINARY_SIZE=$(du -h "${BINARY_PATH}" | cut -f1)
        log_info "Binary size: ${BINARY_SIZE}"
    fi
    
    # Check if binary is executable
    if [ -x "${BINARY_PATH}" ]; then
        log_success "Binary is executable"
    else
        log_warning "Binary is not executable. Setting executable permissions..."
        chmod +x "${BINARY_PATH}"
    fi
    
    # Display version information if available
    if [ -x "${BINARY_PATH}" ]; then
        log_info "Version information:"
        "${BINARY_PATH}" --version 2>&1 || true
    fi
else
    log_error "Build failed"
    exit 1
fi
