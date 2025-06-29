#!/bin/bash
# Script to check system requirements for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "📋 Checking requirements..."

# Check for Rust
if ! command_exists rustc; then
    log_error "Rust not found. Please install Rust from https://rustup.rs/"
fi

# Check for Cargo
if ! command_exists cargo; then
    log_error "Cargo not found. Please install Rust and Cargo from https://rustup.rs/"
fi

log_success "Rust $(rustc --version) found"

# Check for Node.js (optional for GUI)
if command_exists node; then
    log_success "Node.js $(node --version) found"
else
    log_warning "Node.js not found - GUI will not be available"
fi

log_success "All required dependencies are installed"
