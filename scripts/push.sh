#!/bin/bash
# Script to push SView to remote repositories

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

push_changes() {
    log_info "🚀 Pushing changes to remote repositories..."
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    # Get current branch name
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if there are changes to commit
    if [ -n "$(git status --porcelain)" ]; then
        log_info "Staging all changes..."
        git add .
        
        log_info "Committing changes..."
        git commit -m "chore: update project files"
    else
        log_info "No changes to commit."
    fi
    
    # Push to remote
    log_info "Pushing to origin/${current_branch}..."
    if git push -u origin "${current_branch}"; then
        log_success "✅ Successfully pushed to origin/${current_branch}"
        
        # Check if there are tags to push
        local tags_to_push
        tags_to_push=$(git tag --points-at HEAD)
        if [ -n "$tags_to_push" ]; then
            log_info "Pushing tags..."
            git push --tags
        fi
    else
        log_error "Failed to push to origin/${current_branch}"
        exit 1
    fi
}

# Main execution
push_changes
