#!/bin/bash
# Update GitHub OAuth credentials for Cloud Native Docs

set -e

NAMESPACE="cn-docs"
DEPLOYMENT="cn-docs"

echo "🔧 Updating GitHub OAuth credentials for Cloud Native Docs..."

# Check if credentials are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ Usage: $0 <GITHUB_CLIENT_ID> <GITHUB_CLIENT_SECRET>"
    echo ""
    echo "📋 To get these values:"
    echo "1. Go to GitHub → Settings → Developer settings → OAuth Apps"
    echo "2. Create new OAuth App with:"
    echo "   - Homepage URL: https://cn-docs.apps.ocp-5.datsci.softergee.si"
    echo "   - Callback URL: https://cn-docs.apps.ocp-5.datsci.softergee.si/api/auth/callback/github"
    echo "3. Copy Client ID and Client Secret"
    exit 1
fi

GITHUB_ID="$1"
GITHUB_SECRET="$2"

echo "🚀 Setting GitHub OAuth credentials..."
oc set env deployment/$DEPLOYMENT \
  GITHUB_ID="$GITHUB_ID" \
  GITHUB_SECRET="$GITHUB_SECRET" \
  -n $NAMESPACE

echo "⏳ Waiting for deployment to update..."
oc rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=120s

echo "✅ GitHub OAuth credentials updated successfully!"
echo ""
echo "🌐 Test the application at:"
echo "   https://cn-docs.apps.ocp-5.datsci.softergee.si"
echo ""
echo "🔐 GitHub OAuth should now work properly!"
