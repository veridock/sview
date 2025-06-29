#!/bin/bash
# Common functions and variables for SView scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
    exit 1
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Load environment variables
load_env() {
    # Load from .env file if it exists
    if [ -f "$(git rev-parse --show-toplevel)/.env" ]; then
        set -a
        # shellcheck source=/dev/null
        source "$(git rev-parse --show-toplevel)/.env"
        set +a
    fi
}

# Initialize environment
init_environment() {
    # Set project root
    export PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    
    # Set default values if not already set
    export PROJECT_NAME=${PROJECT_NAME:-sview}
    export VERSION=${VERSION:-1.0.0}
    export SRC_DIR=${SRC_DIR:-${PROJECT_ROOT}/src}
    export GUI_DIR=${GUI_DIR:-${PROJECT_ROOT}/gui}
    export DIST_DIR=${DIST_DIR:-${PROJECT_ROOT}/dist}
    export TARGET_DIR=${TARGET_DIR:-${PROJECT_ROOT}/target}
    export EXAMPLES_DIR=${EXAMPLES_DIR:-${PROJECT_ROOT}/examples}
    export DOCS_DIR=${DOCS_DIR:-${PROJECT_ROOT}/docs}
    export CARGO_FLAGS=${CARGO_FLAGS:---release --no-default-features --features=encryption,watch}
    export NPM_FLAGS=${NPM_FLAGS:---production}
    export RUSTFLAGS=${RUSTFLAGS:--C target-cpu=native}
    
    # Add project root to PATH
    export PATH="${PROJECT_ROOT}/target/release:${PATH}"
    
    # Load environment variables
    load_env
}

# Call init_environment when this script is sourced
init_environment
