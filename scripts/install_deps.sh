#!/bin/bash
# Script to install dependencies for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "📦 Installing dependencies..."

# Print cargo version
log_info "Using $(cargo --version)"

# Install Node.js dependencies if GUI directory exists
if [ -f "${GUI_DIR}/package.json" ]; then
    log_info "Installing Node.js dependencies..."
    cd "${GUI_DIR}" && npm install ${NPM_FLAGS}
    log_success "Node.js dependencies installed"
else
    log_warning "No package.json found in ${GUI_DIR}. Skipping Node.js dependencies."
fi

# Install Rust dependencies
log_info "Installing Rust dependencies..."
cargo fetch
log_success "Rust dependencies installed"

log_success "All dependencies installed"
