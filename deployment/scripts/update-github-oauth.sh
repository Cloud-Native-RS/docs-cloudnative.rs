#!/bin/bash

# GitHub OAuth Update Script for OpenShift
# This script updates GitHub OAuth credentials in OpenShift deployment

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
HELM_CHART_DIR="./infrastructure/helm"

echo -e "${GREEN}🔧 Updating GitHub OAuth credentials for CN Docs...${NC}"

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ OpenShift CLI (oc) is not installed.${NC}"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed.${NC}"
    exit 1
fi

# Check if logged in to OpenShift
if ! oc whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to OpenShift. Please login first.${NC}"
    exit 1
fi

# Check if project exists
if ! oc get project ${PROJECT_NAME} &> /dev/null; then
    echo -e "${RED}❌ Project ${PROJECT_NAME} not found. Please deploy the application first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Connected to OpenShift project: ${PROJECT_NAME}${NC}"

# Get GitHub OAuth credentials
echo -e "${YELLOW}📝 Please provide GitHub OAuth credentials:${NC}"
echo -e "${BLUE}   You can get these from: https://github.com/settings/developers${NC}"
echo ""

read -p "GitHub Client ID: " GITHUB_ID
read -s -p "GitHub Client Secret: " GITHUB_SECRET
echo ""

if [ -z "$GITHUB_ID" ] || [ -z "$GITHUB_SECRET" ]; then
    echo -e "${RED}❌ GitHub ID and Secret are required${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GitHub credentials received${NC}"

# Update Helm deployment with new credentials
echo -e "${YELLOW}🔧 Updating deployment with new GitHub OAuth credentials...${NC}"

helm upgrade ${APP_NAME} ${HELM_CHART_DIR} \
    --namespace ${PROJECT_NAME} \
    --set env.GITHUB_ID="${GITHUB_ID}" \
    --set env.GITHUB_SECRET="${GITHUB_SECRET}" \
    --wait --timeout=5m

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ GitHub OAuth credentials updated successfully!${NC}"
else
    echo -e "${RED}❌ Failed to update GitHub OAuth credentials${NC}"
    exit 1
fi

# Check deployment status
echo -e "${YELLOW}📊 Checking deployment status...${NC}"
oc get pods -n ${PROJECT_NAME}

# Get application URL
APP_URL=$(oc get route ${APP_NAME} -n ${PROJECT_NAME} -o jsonpath='{.spec.host}' 2>/dev/null || echo "")
if [ ! -z "$APP_URL" ]; then
    echo -e "${GREEN}🌐 Application is available at: https://${APP_URL}${NC}"
    echo -e "${BLUE}🔗 Custom domain: https://docs.cloudnative.rs${NC}"
fi

echo ""
echo -e "${GREEN}🎉 GitHub OAuth update completed!${NC}"
echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "${BLUE}  1. Test GitHub authentication at: https://docs.cloudnative.rs${NC}"
echo -e "${BLUE}  2. Verify that login works correctly${NC}"
echo -e "${BLUE}  3. Check application logs if there are any issues${NC}"

echo ""
echo -e "${YELLOW}📋 Useful commands:${NC}"
echo -e "${BLUE}  View logs: oc logs -f deployment/${APP_NAME} -n ${PROJECT_NAME}${NC}"
echo -e "${BLUE}  Check pods: oc get pods -n ${PROJECT_NAME}${NC}"
echo -e "${BLUE}  Check routes: oc get routes -n ${PROJECT_NAME}${NC}"
