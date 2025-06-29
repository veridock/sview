#!/bin/bash
# Script to build Docker image for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "🐳 Building Docker image..."

# Create Dockerfile
cat > "${PROJECT_ROOT}/Dockerfile" <<EOF
FROM rust:${RUST_VERSION} as builder
WORKDIR /app
COPY . .
RUN cargo build --release --all-features

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    chromium-browser \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/sview /usr/local/bin/

# Set up user
RUN useradd -m appuser
WORKDIR /home/appuser
USER appuser

# Default command
CMD ["sview"]
EOF

# Build Docker image
if command -v docker >/dev/null 2>&1; then
    docker build -t "${PROJECT_NAME}:${VERSION}" "${PROJECT_ROOT}"
    log_success "✅ Docker image built successfully"
    echo "  To run: docker run -it --rm ${PROJECT_NAME}:${VERSION}"
else
    log_error "❌ Docker not found. Please install Docker to build the image."
    exit 1
fi
