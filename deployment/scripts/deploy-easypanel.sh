#!/bin/bash

# EasyPanel Deployment Script for Cloud Native Docs
# This script deploys the app on port 8080 to avoid conflict with EasyPanel (port 3000)

set -e

echo "🚀 Starting EasyPanel deployment on port 8080..."

# Configuration
CONTAINER_NAME="cloud-native-docs-easypanel"
IMAGE_NAME="darioristic/cloud-native-docs:latest"
PUBLISHED_PORT="8080"
CONTAINER_PORT="3000"

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed. Please install Docker first."
        exit 1
    else
        echo "✅ Docker is installed"
    fi
}

# Function to check if port 8080 is available
check_port() {
    if netstat -tuln | grep -q ":8080 "; then
        echo "⚠️  Port 8080 is already in use"
        echo "Please stop the service using port 8080 or choose a different port"
        exit 1
    else
        echo "✅ Port 8080 is available"
    fi
}

# Function to stop and remove existing container
cleanup_existing() {
    if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
        echo "🧹 Stopping and removing existing container..."
        docker stop $CONTAINER_NAME || true
        docker rm $CONTAINER_NAME || true
        echo "✅ Cleanup completed"
    fi
}

# Function to pull latest image
pull_image() {
    echo "📥 Pulling latest Docker image..."
    docker pull $IMAGE_NAME
    echo "✅ Image pulled successfully"
}

# Function to run container on port 8080
run_container() {
    echo "🐳 Starting container on port 8080..."
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PUBLISHED_PORT:$CONTAINER_PORT \
        --restart unless-stopped \
        -e NODE_ENV=production \
        -e NEXT_TELEMETRY_DISABLED=1 \
        $IMAGE_NAME
    
    echo "✅ Container started successfully"
    
    # Get server IP
    SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "your-server-ip")
    echo "🌐 Application is available at: http://$SERVER_IP:$PUBLISHED_PORT"
}

# Function to show container status
show_status() {
    echo "📊 Container status:"
    docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "📋 Management commands:"
    echo "  View logs: docker logs $CONTAINER_NAME"
    echo "  Stop:      docker stop $CONTAINER_NAME"
    echo "  Restart:   docker restart $CONTAINER_NAME"
    echo "  Remove:    docker rm $CONTAINER_NAME"
    
    echo ""
    echo "🔧 Port configuration:"
    echo "  Published Port: $PUBLISHED_PORT (external)"
    echo "  Container Port: $CONTAINER_PORT (internal)"
    echo "  No conflict with EasyPanel (port 3000)"
}

# Main deployment process
main() {
    echo "🔍 Checking system requirements..."
    check_docker
    check_port
    
    cleanup_existing
    pull_image
    run_container
    
    # Wait a moment for container to start
    sleep 5
    
    show_status
    
    echo ""
    echo "🎉 EasyPanel deployment completed successfully!"
    echo "📖 Cloud Native Documentation is running on port 8080!"
    echo "⚠️  Remember: EasyPanel runs on port 3000, your app runs on port 8080"
}

# Run main function
main "$@"
