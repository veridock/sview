#!/bin/bash
# Script to build the SView GUI

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "🖥️  Building GUI..."

# Check if GUI directory exists
if [ ! -d "${GUI_DIR}" ]; then
    log_warning "GUI directory not found at ${GUI_DIR}, skipping GUI build"
    exit 0
fi

# Navigate to GUI directory
cd "${GUI_DIR}"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    log_warning "No package.json found in ${GUI_DIR}, skipping GUI build"
    exit 0
fi

# Install GUI dependencies if needed
if [ ! -d "node_modules" ]; then
    log_info "Installing GUI dependencies..."
    if ! npm install ${NPM_FLAGS}; then
        log_error "Failed to install GUI dependencies"
        exit 1
    fi
    log_success "GUI dependencies installed"
fi

# Build the GUI
log_info "Building GUI with: npm run build"
if npm run build; then
    GUI_DIST_DIR="${GUI_DIR}/dist"
    log_success "GUI build completed"
    log_info "GUI build output: ${GUI_DIST_DIR}"
    
    # Check if build output exists
    if [ -d "${GUI_DIST_DIR}" ]; then
        log_info "GUI build output contains:"
        ls -la "${GUI_DIST_DIR}" || true
    else
        log_warning "GUI build directory not found at ${GUI_DIST_DIR}"
    fi
else
    log_error "GUI build failed"
    exit 1
fi
