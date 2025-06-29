#!/bin/bash
# Script to run security audits for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "🔒 Running security audit..."

# Run cargo audit for Rust dependencies
if command -v cargo-audit >/dev/null 2>&1; then
    log_info "Running cargo audit..."
    cargo audit
else
    log_warning "⚠️  cargo-audit not found. Install with: cargo install cargo-audit"
fi

# Run npm audit for GUI dependencies if GUI directory exists
if [ -d "${GUI_DIR}" ]; then
    log_info "Running npm audit..."
    (cd "${GUI_DIR}" && npm audit)
fi

log_success "✅ Security audit completed"
