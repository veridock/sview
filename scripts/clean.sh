#!/bin/bash
# Script to clean build artifacts

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

clean_project() {
    log_info "🧹 Cleaning project..."
    
    # Clean Rust target directory
    if [ -d "${TARGET_DIR}" ]; then
        log_info "Removing Rust target directory..."
        cargo clean
    else
        log_info "Rust target directory not found, skipping..."
    fi
    
    # Clean GUI node_modules if they exist
    if [ -d "${GUI_DIR}/node_modules" ]; then
        log_info "Removing GUI node_modules..."
        rm -rf "${GUI_DIR}/node_modules"
    fi
    
    # Clean distribution directory
    if [ -d "${DIST_DIR}" ]; then
        log_info "Removing distribution directory..."
        rm -rf "${DIST_DIR}"
    fi
    
    # Clean any temporary files
    find . -type f -name "*.log" -delete
    find . -type f -name "*.tmp" -delete
    
    log_success "✅ Project cleaned successfully"
}

# Main execution
clean_project
