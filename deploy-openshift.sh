#!/bin/bash

# OpenShift Deployment Script for CN Docs
# This script deploys the application to OpenShift using Helm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="cn-docs"
APP_NAME="cn-docs"
IMAGE_TAG=${1:-"latest"}
HELM_CHART_DIR="./helm"

echo -e "${GREEN}🚀 Starting OpenShift deployment for CN Docs...${NC}"

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ OpenShift CLI (oc) is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if logged in to OpenShift
if ! oc whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to OpenShift. Please login first:${NC}"
    echo "oc login --token=<your-token> --server=<your-server>"
    exit 1
fi

echo -e "${GREEN}✅ OpenShift CLI and Helm are available${NC}"

# Create or switch to project
echo -e "${YELLOW}📁 Creating/selecting OpenShift project: ${PROJECT_NAME}${NC}"
oc new-project ${PROJECT_NAME} --display-name="Cloud Native Documentation" --description="Documentation for Cloud Native platform" 2>/dev/null || oc project ${PROJECT_NAME}

# Check if project exists
if ! oc get project ${PROJECT_NAME} &> /dev/null; then
    echo -e "${RED}❌ Failed to create/select project ${PROJECT_NAME}${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project ${PROJECT_NAME} is ready${NC}"

# Deploy using Helm
echo -e "${YELLOW}🔧 Deploying application using Helm...${NC}"
helm upgrade --install ${APP_NAME} ${HELM_CHART_DIR} \
    --namespace ${PROJECT_NAME} \
    --set image.tag=${IMAGE_TAG} \
    --set image.pullPolicy=Always \
    --wait --timeout=10m

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Application deployed successfully!${NC}"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

# Get application status
echo -e "${YELLOW}📊 Application status:${NC}"
oc get pods -n ${PROJECT_NAME}
oc get services -n ${PROJECT_NAME}
oc get routes -n ${PROJECT_NAME}

# Get application URL
APP_URL=$(oc get route ${APP_NAME} -n ${PROJECT_NAME} -o jsonpath='{.spec.host}')
if [ ! -z "$APP_URL" ]; then
    echo -e "${GREEN}🌐 Application is available at: https://${APP_URL}${NC}"
else
    echo -e "${YELLOW}⚠️  Route not found, checking ingress...${NC}"
    oc get ingress -n ${PROJECT_NAME}
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"

# Run route health check
echo ""
echo -e "${YELLOW}🔍 Running route health check...${NC}"
if [[ -f "scripts/route-health-check.sh" ]]; then
    chmod +x scripts/route-health-check.sh
    export NAMESPACE=${PROJECT_NAME}
    export APP_NAME=${APP_NAME}
    export SERVICE_NAME=${APP_NAME}
    export ROUTE_HOSTNAME="cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si"
    
    if ./scripts/route-health-check.sh check; then
        echo -e "${GREEN}✅ Route health check passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Route health check failed, but deployment completed${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Route health check script not found, skipping...${NC}"
fi

echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs: oc logs -f deployment/${APP_NAME} -n ${PROJECT_NAME}"
echo "  Scale up: oc scale deployment/${APP_NAME} --replicas=3 -n ${PROJECT_NAME}"
echo "  View project: oc project ${PROJECT_NAME}"
echo "  Delete project: oc delete project ${PROJECT_NAME}"
echo "  Check route health: ./scripts/route-health-check.sh check"
echo "  Monitor route: ./scripts/route-monitor.sh monitor"
