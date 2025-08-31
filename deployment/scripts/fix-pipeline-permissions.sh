#!/bin/bash

# Fix Tekton Pipeline Permission Issues Script
# This script applies enhanced RBAC configuration and SecurityContextConstraints
# to resolve permission denied errors in OpenShift Tekton pipelines

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="cn-docs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if oc is installed
    if ! command -v oc &> /dev/null; then
        log_error "OpenShift CLI (oc) is not installed or not in PATH"
        exit 1
    fi
    
    # Check if logged in to OpenShift
    if ! oc whoami &> /dev/null; then
        log_error "Not logged in to OpenShift. Please run 'oc login' first"
        exit 1
    fi
    
    # Check if project exists
    if ! oc get project "$NAMESPACE" &> /dev/null; then
        log_warning "Project $NAMESPACE does not exist. Creating it..."
        oc new-project "$NAMESPACE" --description="Cloud Native Documentation Platform" --display-name="CN Docs"
    fi
    
    log_success "Prerequisites check passed"
}

backup_existing_config() {
    log_info "Backing up existing RBAC configuration..."
    
    local backup_dir="$PROJECT_ROOT/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup existing resources if they exist
    for resource in serviceaccount/cn-docs-pipeline-sa serviceaccount/cn-docs-trigger-sa role/cn-docs-pipeline-role role/cn-docs-trigger-role rolebinding/cn-docs-pipeline-rolebinding rolebinding/cn-docs-trigger-rolebinding; do
        if oc get "$resource" -n "$NAMESPACE" &> /dev/null; then
            log_info "Backing up $resource"
            oc get "$resource" -n "$NAMESPACE" -o yaml > "$backup_dir/$(echo $resource | tr '/' '_').yaml"
        fi
    done
    
    log_success "Backup completed in $backup_dir"
}

apply_enhanced_rbac() {
    log_info "Applying enhanced RBAC configuration..."
    
    # Apply the enhanced RBAC configuration
    if oc apply -f "$PROJECT_ROOT/tekton/rbac-enhanced.yaml"; then
        log_success "Enhanced RBAC configuration applied successfully"
    else
        log_error "Failed to apply enhanced RBAC configuration"
        return 1
    fi
}

verify_permissions() {
    log_info "Verifying permissions..."
    
    # Check if service accounts exist
    if oc get serviceaccount cn-docs-pipeline-sa -n "$NAMESPACE" &> /dev/null; then
        log_success "Service account cn-docs-pipeline-sa exists"
    else
        log_error "Service account cn-docs-pipeline-sa not found"
        return 1
    fi
    
    # Check if SecurityContextConstraints exists
    if oc get scc cn-docs-pipeline-scc &> /dev/null; then
        log_success "SecurityContextConstraints cn-docs-pipeline-scc exists"
    else
        log_warning "SecurityContextConstraints cn-docs-pipeline-scc not found (might need cluster admin privileges)"
    fi
    
    # Test permissions by checking if we can list builds
    if oc auth can-i list builds --as=system:serviceaccount:$NAMESPACE:cn-docs-pipeline-sa -n "$NAMESPACE" &> /dev/null; then
        log_success "Service account can list builds"
    else
        log_warning "Service account cannot list builds (checking permissions...)"
    fi
}

update_pipeline() {
    log_info "Updating pipeline configuration..."
    
    # Apply the updated pipeline
    if oc apply -f "$PROJECT_ROOT/tekton/pipeline.yaml"; then
        log_success "Pipeline configuration updated successfully"
    else
        log_error "Failed to update pipeline configuration"
        return 1
    fi
    
    # Apply the updated pipeline run
    if oc apply -f "$PROJECT_ROOT/tekton/pipelinerun.yaml"; then
        log_success "PipelineRun configuration updated successfully"
    else
        log_error "Failed to update PipelineRun configuration"
        return 1
    fi
}

cleanup_failed_runs() {
    log_info "Cleaning up failed pipeline runs..."
    
    # Delete failed pipeline runs to allow fresh start
    oc delete pipelinerun --all -n "$NAMESPACE" --ignore-not-found=true
    
    log_success "Failed pipeline runs cleaned up"
}

show_next_steps() {
    log_info "Permission fixes applied successfully!"
    echo
    echo -e "${GREEN}Next steps:${NC}"
    echo "1. Run the pipeline with the updated configuration:"
    echo "   oc create -f $PROJECT_ROOT/tekton/pipelinerun.yaml"
    echo
    echo "2. Monitor the pipeline run:"
    echo "   oc logs -f -n $NAMESPACE \$(oc get pipelinerun -n $NAMESPACE -o name | head -1)"
    echo
    echo "3. If you still encounter permission issues, check the pod security policy:"
    echo "   oc describe scc cn-docs-pipeline-scc"
    echo
    echo -e "${YELLOW}Note:${NC} The SecurityContextConstraints might require cluster admin privileges to create."
    echo "If you don't have cluster admin access, ask your OpenShift administrator to apply the SCC."
}

# Main execution
main() {
    log_info "Starting Tekton Pipeline Permission Fix"
    echo "======================================"
    
    check_prerequisites
    backup_existing_config
    apply_enhanced_rbac
    verify_permissions
    update_pipeline
    cleanup_failed_runs
    show_next_steps
    
    log_success "Permission fix completed successfully!"
}

# Run main function
main "$@"
