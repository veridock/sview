#!/bin/bash
# Script to build Docker image for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

build_docker() {
    log_info "🐳 Building Docker image..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Build the Docker image
    local image_name="${PROJECT_NAME}:${VERSION}"
    
    log_info "Building Docker image: ${image_name}"
    
    if docker build -t "${image_name}" .; then
        log_success "✅ Docker image built successfully"
        log_info "To run the container:"
        echo "  docker run -it --rm ${image_name}"
    else
        log_error "Failed to build Docker image"
        exit 1
    fi
}

# Main execution
build_docker
