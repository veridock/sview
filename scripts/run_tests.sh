#!/bin/bash
# Script to run tests for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

run_tests() {
    log_info "🧪 Running tests..."
    
    # Run Rust tests
    log_info "Running Rust tests..."
    if ! cargo test --no-fail-fast -- --test-threads=1; then
        log_error "Rust tests failed"
        exit 1
    fi
    
    # Run GUI tests if GUI directory exists
    if [ -d "${GUI_DIR}" ] && [ -f "${GUI_DIR}/package.json" ]; then
        log_info "Running GUI tests..."
        cd "${GUI_DIR}" && npm test
    else
        log_info "Skipping GUI tests - GUI directory not found or no package.json"
    fi
    
    log_success "✅ All tests passed"
}

# Main execution
run_tests
