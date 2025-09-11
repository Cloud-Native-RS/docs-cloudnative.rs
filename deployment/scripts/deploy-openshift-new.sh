#!/bin/bash

# OpenShift Deployment Script for CN Docs
# This script deploys the application to OpenShift using Helm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="cn-docs"
APP_NAME="cn-docs"
IMAGE_TAG=${1:-"latest"}
HELM_CHART_DIR="./infrastructure/helm"
DOCKER_IMAGE="darioristic/cloud-native-docs"

echo -e "${GREEN}🚀 Starting OpenShift deployment for CN Docs...${NC}"
echo -e "${BLUE}📦 Using Docker image: ${DOCKER_IMAGE}:${IMAGE_TAG}${NC}"

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ OpenShift CLI (oc) is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}📥 Install from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/${NC}"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed. Please install it first.${NC}"
    echo -e "${YELLOW}📥 Install from: https://helm.sh/docs/intro/install/${NC}"
    exit 1
fi

# Check if logged in to OpenShift
if ! oc whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to OpenShift. Please login first:${NC}"
    echo -e "${BLUE}oc login --token=<your-token> --server=<your-server>${NC}"
    exit 1
fi

echo -e "${GREEN}✅ OpenShift CLI and Helm are available${NC}"
echo -e "${BLUE}👤 Logged in as: $(oc whoami)${NC}"

# Create or switch to project
echo -e "${YELLOW}📁 Creating/selecting OpenShift project: ${PROJECT_NAME}${NC}"
oc new-project ${PROJECT_NAME} --display-name="Cloud Native Documentation" --description="Documentation for Cloud Native platform" 2>/dev/null || oc project ${PROJECT_NAME}

# Check if project exists
if ! oc get project ${PROJECT_NAME} &> /dev/null; then
    echo -e "${RED}❌ Failed to create/select project ${PROJECT_NAME}${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project ${PROJECT_NAME} is ready${NC}"

# Check if Helm chart directory exists
if [ ! -d "$HELM_CHART_DIR" ]; then
    echo -e "${RED}❌ Helm chart directory not found: ${HELM_CHART_DIR}${NC}"
    exit 1
fi

# Deploy using Helm
echo -e "${YELLOW}🔧 Deploying application using Helm...${NC}"
echo -e "${BLUE}📋 Chart directory: ${HELM_CHART_DIR}${NC}"

helm upgrade --install ${APP_NAME} ${HELM_CHART_DIR} \
    --namespace ${PROJECT_NAME} \
    --set image.repository=${DOCKER_IMAGE} \
    --set image.tag=${IMAGE_TAG} \
    --set image.pullPolicy=Always \
    --set openshift.route.host=docs.cloudnative.rs \
    --wait --timeout=10m

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Application deployed successfully!${NC}"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

# Get application status
echo -e "${YELLOW}📊 Application status:${NC}"
echo -e "${BLUE}📦 Pods:${NC}"
oc get pods -n ${PROJECT_NAME}

echo -e "${BLUE}🔗 Services:${NC}"
oc get services -n ${PROJECT_NAME}

echo -e "${BLUE}🛣️  Routes:${NC}"
oc get routes -n ${PROJECT_NAME}

# Get application URL
APP_URL=$(oc get route ${APP_NAME} -n ${PROJECT_NAME} -o jsonpath='{.spec.host}' 2>/dev/null || echo "")
if [ ! -z "$APP_URL" ]; then
    echo -e "${GREEN}🌐 Application is available at: https://${APP_URL}${NC}"
    echo -e "${BLUE}🔗 Custom domain: https://docs.cloudnative.rs${NC}"
else
    echo -e "${YELLOW}⚠️  Route not found, checking ingress...${NC}"
    oc get ingress -n ${PROJECT_NAME}
fi

# Check if pods are running
echo -e "${YELLOW}🔍 Checking pod status...${NC}"
READY_PODS=$(oc get pods -n ${PROJECT_NAME} --field-selector=status.phase=Running --no-headers | wc -l)
TOTAL_PODS=$(oc get pods -n ${PROJECT_NAME} --no-headers | wc -l)

if [ "$READY_PODS" -eq "$TOTAL_PODS" ] && [ "$READY_PODS" -gt 0 ]; then
    echo -e "${GREEN}✅ All pods are running (${READY_PODS}/${TOTAL_PODS})${NC}"
else
    echo -e "${YELLOW}⚠️  Some pods are not ready (${READY_PODS}/${TOTAL_PODS})${NC}"
    echo -e "${BLUE}📋 Pod details:${NC}"
    oc get pods -n ${PROJECT_NAME}
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
    export ROUTE_HOSTNAME="docs.cloudnative.rs"
    
    if ./scripts/route-health-check.sh check; then
        echo -e "${GREEN}✅ Route health check passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Route health check failed, but deployment completed${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Route health check script not found, skipping...${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Useful commands:${NC}"
echo -e "${BLUE}  View logs: oc logs -f deployment/${APP_NAME} -n ${PROJECT_NAME}${NC}"
echo -e "${BLUE}  Scale up: oc scale deployment/${APP_NAME} --replicas=3 -n ${PROJECT_NAME}${NC}"
echo -e "${BLUE}  View project: oc project ${PROJECT_NAME}${NC}"
echo -e "${BLUE}  Delete project: oc delete project ${PROJECT_NAME}${NC}"
echo -e "${BLUE}  Check route health: ./scripts/route-health-check.sh check${NC}"
echo -e "${BLUE}  Monitor route: ./scripts/route-monitor.sh monitor${NC}"

echo ""
echo -e "${GREEN}🎯 Next steps:${NC}"
echo -e "${BLUE}  1. Update GitHub OAuth App with callback URL: https://docs.cloudnative.rs/api/auth/callback/github${NC}"
echo -e "${BLUE}  2. Update GITHUB_ID and GITHUB_SECRET in Helm values${NC}"
echo -e "${BLUE}  3. Test the application at: https://docs.cloudnative.rs${NC}"
