#!/bin/bash

echo "🔍 CN-Docs Application Troubleshooting Script"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if logged in to OpenShift
print_status "Checking OpenShift login status..."
if ! oc whoami &>/dev/null; then
    print_error "Not logged in to OpenShift!"
    echo "Please log in first:"
    echo "oc login --token=<your-token> --server=https://api.ocp-5.datsci.softergee.si:6443"
    exit 1
fi

print_status "Logged in as: $(oc whoami)"

# Switch to cn-docs project
print_status "Switching to cn-docs project..."
if ! oc project cn-docs &>/dev/null; then
    print_error "cn-docs project doesn't exist!"
    print_status "Creating cn-docs project..."
    oc new-project cn-docs
fi

# Check deployment
print_status "Checking deployment status..."
DEPLOYMENT_EXISTS=$(oc get deployment cn-docs -n cn-docs --no-headers 2>/dev/null | wc -l)

if [ "$DEPLOYMENT_EXISTS" -eq 0 ]; then
    print_warning "No deployment found. Creating new deployment..."
    
    # Create deployment using the built image first, fallback to S2I
    if oc get imagestream cn-docs -n cn-docs &>/dev/null; then
        print_status "Using existing image from imagestream..."
        oc new-app cn-docs:latest --name=cn-docs
    else
        print_status "Creating S2I deployment from source..."
        oc new-app nodejs:18-ubi9~https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git \
            --name=cn-docs \
            --env NPM_CONFIG_PRODUCTION=false \
            --env NODE_ENV=production
    fi
else
    print_status "Deployment exists. Checking status..."
    oc get deployment cn-docs -n cn-docs
fi

# Check pods
print_status "Checking pod status..."
POD_STATUS=$(oc get pods -l app=cn-docs -n cn-docs --no-headers 2>/dev/null)
if [ -z "$POD_STATUS" ]; then
    print_warning "No pods found for cn-docs app"
else
    echo "$POD_STATUS"
    
    # Check if any pods are not running
    FAILED_PODS=$(echo "$POD_STATUS" | grep -v "Running" | grep -v "Completed" || true)
    if [ ! -z "$FAILED_PODS" ]; then
        print_warning "Some pods are not running:"
        echo "$FAILED_PODS"
        
        # Get logs from failed pods
        print_status "Getting logs from failed pods..."
        POD_NAMES=$(echo "$FAILED_PODS" | awk '{print $1}')
        for pod in $POD_NAMES; do
            echo "--- Logs for $pod ---"
            oc logs $pod -n cn-docs --tail=50
            echo ""
        done
    fi
fi

# Check service
print_status "Checking service..."
SERVICE_EXISTS=$(oc get service cn-docs -n cn-docs --no-headers 2>/dev/null | wc -l)
if [ "$SERVICE_EXISTS" -eq 0 ]; then
    print_warning "Service doesn't exist. Creating service..."
    oc expose deployment cn-docs --port=3000 --target-port=3000 -n cn-docs
else
    print_status "Service exists:"
    oc get service cn-docs -n cn-docs
    
    # Check endpoints
    print_status "Checking service endpoints..."
    oc get endpoints cn-docs -n cn-docs
fi

# Check route
print_status "Checking route..."
ROUTE_EXISTS=$(oc get route cn-docs -n cn-docs --no-headers 2>/dev/null | wc -l)
if [ "$ROUTE_EXISTS" -eq 0 ]; then
    print_warning "Route doesn't exist. Creating route..."
    oc expose service cn-docs --hostname=cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si -n cn-docs
else
    print_status "Route exists:"
    oc get route cn-docs -n cn-docs
    
    # Check if hostname matches expected
    CURRENT_HOST=$(oc get route cn-docs -n cn-docs -o jsonpath='{.spec.host}')
    EXPECTED_HOST="cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si"
    
    if [ "$CURRENT_HOST" != "$EXPECTED_HOST" ]; then
        print_warning "Route hostname mismatch!"
        print_warning "Current: $CURRENT_HOST"
        print_warning "Expected: $EXPECTED_HOST"
        print_status "Recreating route with correct hostname..."
        oc delete route cn-docs -n cn-docs
        oc expose service cn-docs --hostname=$EXPECTED_HOST -n cn-docs
    fi
fi

# Final status check
print_status "Final application status:"
echo "=================================="
echo "Deployment:"
oc get deployment cn-docs -n cn-docs 2>/dev/null || echo "No deployment found"
echo ""
echo "Pods:"
oc get pods -l app=cn-docs -n cn-docs 2>/dev/null || echo "No pods found"
echo ""
echo "Service:"
oc get service cn-docs -n cn-docs 2>/dev/null || echo "No service found"
echo ""
echo "Route:"
oc get route cn-docs -n cn-docs 2>/dev/null || echo "No route found"
echo ""

# Application URL
ROUTE_URL=$(oc get route cn-docs -n cn-docs -o jsonpath='{.spec.host}' 2>/dev/null)
if [ ! -z "$ROUTE_URL" ]; then
    print_status "Application should be available at: https://$ROUTE_URL"
else
    print_error "No route URL found"
fi

# Recent events
print_status "Recent events (last 10):"
oc get events -n cn-docs --sort-by='.lastTimestamp' | tail -10

echo ""
print_status "Troubleshooting complete!"
