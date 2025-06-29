#!/bin/bash
# Script to install SView locally

set -e

# Source common variables and functions
source "$(dirname "$0")/common.sh"

log_info "📦 Installing SView locally..."

# Create necessary directories
mkdir -p ~/.local/bin
mkdir -p ~/.sview/{cache,config,logs}

# Copy binary
cp "${TARGET_DIR}/release/${PROJECT_NAME}" ~/.local/bin/

# Make it executable
chmod +x "${HOME}/.local/bin/${PROJECT_NAME}"

log_success "✅ SView installed successfully to ~/.local/bin/${PROJECT_NAME}"
log_info "\nTo use SView, you may need to add ~/.local/bin to your PATH:"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true

log_info "\nTo complete the installation, run one of these commands:"
echo '  source ~/.bashrc  # If using bash'
echo '  source ~/.zshrc   # If using zsh'

log_info "\nThen verify the installation with:"
echo "  ${PROJECT_NAME} --version"
