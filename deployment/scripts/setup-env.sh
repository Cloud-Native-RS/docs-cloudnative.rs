#!/bin/bash

# Environment Setup Script for docs.cloudnative.rs
# This script creates the .env file on your production server

set -e

echo "🔧 Setting up environment variables for docs.cloudnative.rs..."

# Configuration
ENV_FILE="/opt/cloud-native-docs/.env"
BACKUP_FILE="/opt/cloud-native-docs/.env.backup.$(date +%Y%m%d_%H%M%S)"

# Create directory if it doesn't exist
mkdir -p /opt/cloud-native-docs

# Backup existing .env file if it exists
if [ -f "$ENV_FILE" ]; then
    echo "📋 Backing up existing .env file..."
    cp "$ENV_FILE" "$BACKUP_FILE"
    echo "✅ Backup created: $BACKUP_FILE"
fi

# Create new .env file
echo "📝 Creating new .env file..."
cat > "$ENV_FILE" << 'EOF'
# Production Environment Variables for docs.cloudnative.rs
# Generated on: $(date)

# NextAuth.js Configuration
NEXTAUTH_URL=https://docs.cloudnative.rs
NEXTAUTH_SECRET=lpoOS0yqIpGIzfmSQxzWAu4Ca4WatstrHjThptAzrbw=

# GitHub OAuth App Configuration
# Create a GitHub OAuth App at: https://github.com/settings/developers
# 
# Production URLs:
# Homepage URL: https://docs.cloudnative.rs
# Authorization callback URL: https://docs.cloudnative.rs/api/auth/callback/github
GITHUB_ID=your-github-client-id
GITHUB_SECRET=your-github-client-secret

# GitHub Organization Access Control
# Only members of this organization will be allowed to login
GITHUB_ORG=Cloud-Native-RS

# Node Environment
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1

# Optional: Custom domain configuration
# ASSET_PREFIX=https://docs.cloudnative.rs
EOF

# Set proper permissions
chmod 600 "$ENV_FILE"
chown root:root "$ENV_FILE"

echo "✅ Environment file created: $ENV_FILE"
echo ""
echo "⚠️  IMPORTANT: You need to update the following values:"
echo "   1. GITHUB_ID - Your GitHub OAuth App Client ID"
echo "   2. GITHUB_SECRET - Your GitHub OAuth App Client Secret"
echo ""
echo "📖 To get GitHub OAuth credentials:"
echo "   1. Go to: https://github.com/settings/developers"
echo "   2. Create new OAuth App"
echo "   3. Set Homepage URL: https://docs.cloudnative.rs"
echo "   4. Set Callback URL: https://docs.cloudnative.rs/api/auth/callback/github"
echo ""
echo "🔧 To edit the file:"
echo "   sudo nano $ENV_FILE"
echo ""
echo "🚀 After updating credentials, restart your application:"
echo "   docker restart cloud-native-docs"
