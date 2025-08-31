#!/bin/bash

echo "🚀 Manual CN-Docs Deployment Script"
echo "===================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if logged in
if ! oc whoami &>/dev/null; then
    print_error "Not logged in to OpenShift!"
    echo "Please log in first:"
    echo "oc login --token=<your-token> --server=https://api.ocp-5.datsci.softergee.si:6443"
    exit 1
fi

print_status "Logged in as: $(oc whoami)"

# Create/switch to project
print_status "Creating/switching to cn-docs project..."
oc new-project cn-docs 2>/dev/null || oc project cn-docs

# Clean up existing resources (optional)
read -p "Do you want to clean up existing cn-docs resources? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Cleaning up existing resources..."
    oc delete all -l app=cn-docs -n cn-docs 2>/dev/null || true
    oc delete route cn-docs -n cn-docs 2>/dev/null || true
    sleep 5
fi

# Deploy using S2I (Source-to-Image)
print_status "Creating new application using S2I..."
oc new-app nodejs:18-ubi9~https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git \
    --name=cn-docs \
    --env NODE_ENV=production \
    --env NPM_CONFIG_PRODUCTION=false

# Wait for build to start
print_status "Waiting for build to start..."
sleep 10

# Follow the build
print_status "Following the build process..."
oc logs -f bc/cn-docs || true

# Wait for deployment
print_status "Waiting for deployment to complete..."
oc rollout status deployment/cn-docs --timeout=600s

# Expose the service
print_status "Exposing the service..."
oc expose service cn-docs --hostname=cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si

# Final status
print_status "Deployment completed! Application status:"
echo "================================================"
echo "Pods:"
oc get pods -l app=cn-docs
echo ""
echo "Service:"
oc get service cn-docs
echo ""
echo "Route:"
oc get route cn-docs
echo ""

ROUTE_URL=$(oc get route cn-docs -o jsonpath='{.spec.host}' 2>/dev/null)
if [ ! -z "$ROUTE_URL" ]; then
    print_status "🎉 Application is available at: https://$ROUTE_URL"
    
    # Test the application
    print_status "Testing application availability..."
    sleep 30
    if curl -s -o /dev/null -w "%{http_code}" "https://$ROUTE_URL" | grep -q "200\|301\|302"; then
        print_status "✅ Application is responding!"
    else
        print_warning "⚠️  Application might not be ready yet. Please wait a few minutes and try again."
    fi
else
    print_error "❌ Route URL not found"
fi

echo ""
print_status "Manual deployment complete!"
