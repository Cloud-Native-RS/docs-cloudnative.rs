#!/bin/bash

# OpenShift Tekton Pipeline Deployment Script
# This script deploys the Tekton CI/CD pipeline to OpenShift

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="cn-docs"
TEKTON_DIR="./tekton"

echo -e "${BLUE}🚀 Deploying OpenShift Tekton CI/CD Pipeline...${NC}"

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    echo -e "${RED}❌ OpenShift CLI (oc) is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if logged in to OpenShift
if ! oc whoami &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to OpenShift. Please login first:${NC}"
    echo "oc login --token=<your-token> --server=<your-server>"
    exit 1
fi

echo -e "${GREEN}✅ OpenShift CLI is available${NC}"

# Check if Tekton is installed
echo -e "${YELLOW}🔍 Checking if Tekton is installed...${NC}"
if ! oc get crd pipelineruns.tekton.dev &> /dev/null; then
    echo -e "${RED}❌ Tekton is not installed on this OpenShift cluster.${NC}"
    echo -e "${YELLOW}📋 Please install Tekton first:${NC}"
    echo "1. Go to OpenShift Console → Operators → OperatorHub"
    echo "2. Search for 'Tekton' and install 'Red Hat OpenShift Pipelines'"
    echo "3. Wait for installation to complete"
    exit 1
fi

echo -e "${GREEN}✅ Tekton is installed${NC}"

# Create or switch to project
echo -e "${YELLOW}📁 Creating/selecting OpenShift project: ${PROJECT_NAME}${NC}"
oc new-project ${PROJECT_NAME} --display-name="Cloud Native Documentation" --description="Documentation for Cloud Native platform" 2>/dev/null || oc project ${PROJECT_NAME}

# Check if project exists
if ! oc get project ${PROJECT_NAME} &> /dev/null; then
    echo -e "${RED}❌ Failed to create/select project ${PROJECT_NAME}${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project ${PROJECT_NAME} is ready${NC}"

# Deploy RBAC first
echo -e "${YELLOW}🔐 Deploying RBAC and ServiceAccounts...${NC}"
oc apply -f ${TEKTON_DIR}/rbac.yaml

# Deploy Tekton pipeline
echo -e "${YELLOW}🔧 Deploying Tekton pipeline...${NC}"
oc apply -f ${TEKTON_DIR}/pipeline.yaml

# Deploy triggers
echo -e "${YELLOW}🎯 Deploying Tekton triggers...${NC}"
oc apply -f ${TEKTON_DIR}/trigger.yaml

# Create GitHub webhook secret (if not exists)
echo -e "${YELLOW}🔑 Creating GitHub webhook secret...${NC}"
if ! oc get secret github-webhook-secret -n ${PROJECT_NAME} &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub webhook secret not found. Creating placeholder...${NC}"
    oc create secret generic github-webhook-secret \
        --from-literal=secretToken="your-github-webhook-secret-here" \
        -n ${PROJECT_NAME}
    echo -e "${YELLOW}📝 Please update the secret with your actual GitHub webhook secret:${NC}"
    echo "oc patch secret github-webhook-secret -n ${PROJECT_NAME} --type='json' -p='[{\"op\": \"replace\", \"path\": \"/data/secretToken\", \"value\": \"$(echo -n 'your-actual-secret' | base64)\"}]'"
fi

# Wait for EventListener to be ready
echo -e "${YELLOW}⏳ Waiting for EventListener to be ready...${NC}"
oc wait --for=condition=ready pod -l app=cn-docs-event-listener -n ${PROJECT_NAME} --timeout=5m

# Get EventListener service URL
echo -e "${YELLOW}🌐 Getting EventListener service URL...${NC}"
EVENT_LISTENER_URL=$(oc get route cn-docs-event-listener -n ${PROJECT_NAME} -o jsonpath='{.spec.host}' 2>/dev/null || echo "")

if [ ! -z "$EVENT_LISTENER_URL" ]; then
    echo -e "${GREEN}✅ EventListener is available at: https://${EVENT_LISTENER_URL}${NC}"
else
    echo -e "${YELLOW}⚠️  EventListener route not found, checking service...${NC}"
    EVENT_LISTENER_SERVICE=$(oc get service cn-docs-event-listener -n ${PROJECT_NAME} -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
    if [ ! -z "$EVENT_LISTENER_SERVICE" ]; then
        echo -e "${GREEN}✅ EventListener service is available at: ${EVENT_LISTENER_SERVICE}:8080${NC}"
    fi
fi

# Test pipeline manually
echo -e "${YELLOW}🧪 Testing pipeline manually...${NC}"
oc apply -f ${TEKTON_DIR}/pipelinerun.yaml

# Get pipeline status
echo -e "${YELLOW}📊 Pipeline status:${NC}"
oc get pipelineruns -n ${PROJECT_NAME}
oc get pods -n ${PROJECT_NAME} -l tekton.dev/taskRun

echo -e "${GREEN}🎉 Tekton CI/CD Pipeline deployed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. **Update GitHub webhook secret** with your actual secret"
echo "2. **Configure GitHub webhook** to point to your EventListener URL"
echo "3. **Test pipeline** by pushing to main branch"
echo "4. **Monitor pipeline** with: oc get pipelineruns -n ${PROJECT_NAME}"
echo ""
echo -e "${YELLOW}🔗 Useful commands:${NC}"
echo "  View pipeline runs: oc get pipelineruns -n ${PROJECT_NAME}"
echo "  View pipeline logs: oc logs -f pipelinerun/<name> -n ${PROJECT_NAME}"
echo "  Delete pipeline: oc delete pipeline cn-docs-pipeline -n ${PROJECT_NAME}"
echo "  View triggers: oc get eventlistener -n ${PROJECT_NAME}"
echo ""
echo -e "${BLUE}🌐 GitHub Webhook URL:${NC}"
if [ ! -z "$EVENT_LISTENER_URL" ]; then
    echo "https://${EVENT_LISTENER_URL}"
else
    echo "Service: ${EVENT_LISTENER_SERVICE}:8080"
fi
echo ""
echo -e "${YELLOW}📝 To configure GitHub webhook:${NC}"
echo "1. Go to your GitHub repository → Settings → Webhooks"
echo "2. Add webhook with URL: https://${EVENT_LISTENER_URL:-$EVENT_LISTENER_SERVICE:8080}"
echo "3. Set content type to: application/json"
echo "4. Select events: Just the push event"
echo "5. Add secret: your-github-webhook-secret-here"
