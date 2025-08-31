#!/bin/bash

# 🔍 Route Health Check and Auto-Fix Script
# ==========================================

set -euo pipefail

# Configuration
NAMESPACE="${NAMESPACE:-cn-docs}"
APP_NAME="${APP_NAME:-cn-docs}"
SERVICE_NAME="${SERVICE_NAME:-cn-docs}"
ROUTE_HOSTNAME="${ROUTE_HOSTNAME:-cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si}"
MAX_RETRIES=3
RETRY_DELAY=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check if route exists
check_route_exists() {
    oc get route "$APP_NAME" -n "$NAMESPACE" >/dev/null 2>&1
}

# Function to test route health
test_route_health() {
    local url="https://$ROUTE_HOSTNAME"
    local http_code
    
    log_info "Testing route health: $url"
    
    # Test with timeout and get HTTP status code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 30 "$url" || echo "000")
    
    if [[ "$http_code" == "200" ]]; then
        log_success "Route is healthy (HTTP $http_code)"
        return 0
    else
        log_error "Route is unhealthy (HTTP $http_code)"
        return 1
    fi
}

# Function to check internal pod health
check_pod_health() {
    log_info "Checking pod health..."
    
    # Get running pod
    local pod_name
    pod_name=$(oc get pods -l app="$APP_NAME" -n "$NAMESPACE" --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    
    if [[ -z "$pod_name" ]]; then
        log_error "No running pods found for app=$APP_NAME"
        return 1
    fi
    
    log_info "Testing pod $pod_name internal health..."
    
    # Test internal connectivity
    if oc exec "$pod_name" -n "$NAMESPACE" -- sh -c "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 --max-time 10" | grep -q "200"; then
        log_success "Pod internal health check passed"
        return 0
    else
        log_error "Pod internal health check failed"
        return 1
    fi
}

# Function to check service endpoints
check_service_endpoints() {
    log_info "Checking service endpoints..."
    
    local endpoints
    endpoints=$(oc get endpoints "$SERVICE_NAME" -n "$NAMESPACE" -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null || echo "")
    
    if [[ -n "$endpoints" ]]; then
        log_success "Service has healthy endpoints: $endpoints"
        return 0
    else
        log_error "Service has no healthy endpoints"
        return 1
    fi
}

# Function to recreate route
recreate_route() {
    log_warning "Recreating route to fix issues..."
    
    # Delete existing route
    if check_route_exists; then
        log_info "Deleting existing route..."
        oc delete route "$APP_NAME" -n "$NAMESPACE" || log_warning "Failed to delete route"
        sleep 5
    fi
    
    # Create new route with edge TLS
    log_info "Creating new route with edge TLS..."
    oc create route edge "$APP_NAME" \
        --service="$SERVICE_NAME" \
        --hostname="$ROUTE_HOSTNAME" \
        -n "$NAMESPACE"
    
    if [[ $? -eq 0 ]]; then
        log_success "Route recreated successfully"
        return 0
    else
        log_error "Failed to recreate route"
        return 1
    fi
}

# Function to wait for route propagation
wait_for_route_propagation() {
    local max_wait=120  # 2 minutes
    local wait_time=0
    
    log_info "Waiting for route propagation..."
    
    while [[ $wait_time -lt $max_wait ]]; do
        if test_route_health; then
            log_success "Route is now healthy after ${wait_time}s"
            return 0
        fi
        
        sleep 10
        wait_time=$((wait_time + 10))
        log_info "Waiting... (${wait_time}s/${max_wait}s)"
    done
    
    log_error "Route did not become healthy within ${max_wait}s"
    return 1
}

# Main health check and fix function
main() {
    log_info "🔍 Starting route health check for $APP_NAME in namespace $NAMESPACE"
    
    # Check if we're logged in to OpenShift
    if ! oc whoami >/dev/null 2>&1; then
        log_error "Not logged in to OpenShift. Please run 'oc login' first."
        exit 1
    fi
    
    # Switch to the correct namespace
    oc project "$NAMESPACE" >/dev/null 2>&1 || {
        log_error "Failed to switch to namespace $NAMESPACE"
        exit 1
    }
    
    # Check if route exists
    if ! check_route_exists; then
        log_warning "Route does not exist, creating..."
        recreate_route
        wait_for_route_propagation
        exit $?
    fi
    
    # Test route health
    if test_route_health; then
        log_success "✅ Route is healthy, no action needed"
        exit 0
    fi
    
    log_warning "Route is unhealthy, starting diagnostic checks..."
    
    # Check pod health
    if ! check_pod_health; then
        log_error "Pod health check failed. Please check deployment status."
        exit 1
    fi
    
    # Check service endpoints
    if ! check_service_endpoints; then
        log_error "Service endpoints check failed. Please check service configuration."
        exit 1
    fi
    
    # If pod and service are healthy but route is not, recreate route
    log_info "Pod and service are healthy, but route is not. Recreating route..."
    
    for attempt in $(seq 1 $MAX_RETRIES); do
        log_info "Attempt $attempt/$MAX_RETRIES to fix route..."
        
        if recreate_route && wait_for_route_propagation; then
            log_success "✅ Route fixed successfully on attempt $attempt"
            exit 0
        fi
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            log_warning "Attempt $attempt failed, retrying in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
        fi
    done
    
    log_error "❌ Failed to fix route after $MAX_RETRIES attempts"
    exit 1
}

# Handle script arguments
case "${1:-check}" in
    "check")
        main
        ;;
    "test")
        test_route_health
        ;;
    "recreate")
        recreate_route
        wait_for_route_propagation
        ;;
    "help")
        echo "Usage: $0 [check|test|recreate|help]"
        echo "  check    - Full health check and auto-fix (default)"
        echo "  test     - Test route health only"
        echo "  recreate - Force recreate route"
        echo "  help     - Show this help"
        ;;
    *)
        log_error "Invalid argument: $1"
        echo "Usage: $0 [check|test|recreate|help]"
        exit 1
        ;;
esac
