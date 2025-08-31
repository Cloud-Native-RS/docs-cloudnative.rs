#!/bin/bash

# GitHub Webhook Test Script
# This script simulates a real GitHub webhook payload to test the pipeline trigger

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WEBHOOK_URL="http://el-cn-docs-event-listener-cn-docs.apps.ocp-5.datsci.softergee.si"
NAMESPACE="cn-docs"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test webhook with real GitHub payload
test_github_webhook() {
    log_info "Testing GitHub webhook trigger..."
    
    # Get current commit hash
    local commit_hash=$(git rev-parse HEAD)
    local short_commit=${commit_hash:0:7}
    
    log_info "Using commit hash: $commit_hash"
    
    # GitHub webhook payload simulation
    local payload='{
      "ref": "refs/heads/main",
      "before": "0000000000000000000000000000000000000000",
      "after": "'$commit_hash'",
      "repository": {
        "id": 12345678,
        "name": "docs-cloudnative.rs",
        "full_name": "Cloud-Native-RS/docs-cloudnative.rs",
        "owner": {
          "name": "Cloud-Native-RS",
          "login": "Cloud-Native-RS"
        },
        "clone_url": "https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git",
        "html_url": "https://github.com/Cloud-Native-RS/docs-cloudnative.rs"
      },
      "pusher": {
        "name": "test-user",
        "email": "test@example.com"
      },
      "head_commit": {
        "id": "'$commit_hash'",
        "message": "Test webhook trigger",
        "timestamp": "'$(date -Iseconds)'",
        "author": {
          "name": "Test User",
          "email": "test@example.com"
        }
      },
      "commits": [
        {
          "id": "'$commit_hash'",
          "message": "Test webhook trigger",
          "timestamp": "'$(date -Iseconds)'",
          "author": {
            "name": "Test User",
            "email": "test@example.com"
          },
          "added": [],
          "removed": [],
          "modified": ["README.md"]
        }
      ]
    }'
    
    log_info "Sending webhook payload to $WEBHOOK_URL"
    
    # Send webhook request
    local response=$(curl -s -X POST "$WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -H 'X-GitHub-Event: push' \
        -H 'X-GitHub-Delivery: 12345678-1234-1234-1234-123456789012' \
        -d "$payload")
    
    if [[ $? -eq 0 ]]; then
        log_success "Webhook request sent successfully"
        echo "Response: $response"
    else
        log_error "Failed to send webhook request"
        return 1
    fi
}

# Monitor pipeline run
monitor_pipeline() {
    log_info "Monitoring for new pipeline runs..."
    
    # Wait a bit for the pipeline to be created
    sleep 5
    
    # Get the latest pipeline run
    local latest_run=$(oc get pipelinerun -n "$NAMESPACE" --sort-by=.metadata.creationTimestamp -o name | tail -1)
    
    if [[ -n "$latest_run" ]]; then
        local run_name=$(echo $latest_run | cut -d'/' -f2)
        log_success "Found pipeline run: $run_name"
        
        # Show pipeline run status
        oc get pipelinerun "$run_name" -n "$NAMESPACE"
        
        log_info "To follow the pipeline logs, run:"
        echo "oc logs -f -n $NAMESPACE $latest_run"
        
        log_info "To watch pipeline progress, run:"
        echo "oc get pipelinerun $run_name -n $NAMESPACE -w"
        
    else
        log_warning "No pipeline runs found"
    fi
}

# Show webhook setup instructions
show_github_setup() {
    log_info "To set up GitHub webhook:"
    echo "=================================="
    echo "1. Go to: https://github.com/Cloud-Native-RS/docs-cloudnative.rs/settings/hooks"
    echo "2. Click 'Add webhook'"
    echo "3. Payload URL: $WEBHOOK_URL"
    echo "4. Content type: application/json"
    echo "5. Secret: (get from OpenShift secret)"
    echo "6. Events: Just the push event"
    echo "7. Active: ✓"
    echo ""
    
    log_info "To get the webhook secret:"
    echo "oc get secret github-webhook-secret -n $NAMESPACE -o jsonpath='{.data.secretToken}' | base64 -d"
}

# Main execution
main() {
    log_info "GitHub Webhook Test Script"
    echo "=========================="
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
    
    # Check if oc is available
    if ! command -v oc &> /dev/null; then
        log_error "OpenShift CLI (oc) not found"
        exit 1
    fi
    
    test_github_webhook
    monitor_pipeline
    show_github_setup
    
    log_success "Webhook test completed!"
}

# Run main function
main "$@"
