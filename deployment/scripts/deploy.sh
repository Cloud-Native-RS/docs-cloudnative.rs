#!/bin/bash

# Cloud Native Docs VPS Deployment Script
# Run this script on your VPS

set -e

echo "🚀 Starting Cloud Native Docs deployment..."

# Configuration
CONTAINER_NAME="cloud-native-docs"
IMAGE_NAME="darioristic/cloud-native-docs:latest"
PORT="80"

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed. Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        echo "✅ Docker installed successfully"
        echo "⚠️  Please log out and log back in for group changes to take effect"
        exit 1
    else
        echo "✅ Docker is already installed"
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

# Function to run container
run_container() {
    echo "🐳 Starting new container..."
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:3000 \
        --restart unless-stopped \
        -e NODE_ENV=production \
        -e NEXT_TELEMETRY_DISABLED=1 \
        $IMAGE_NAME
    
    echo "✅ Container started successfully"
    echo "🌐 Application is available at: http://$(curl -s ifconfig.me):$PORT"
}

# Function to show container status
show_status() {
    echo "📊 Container status:"
    docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "📋 Quick commands:"
    echo "  View logs: docker logs $CONTAINER_NAME"
    echo "  Stop:      docker stop $CONTAINER_NAME"
    echo "  Restart:   docker restart $CONTAINER_NAME"
    echo "  Remove:    docker rm $CONTAINER_NAME"
}

# Main deployment process
main() {
    echo "🔍 Checking system requirements..."
    check_docker
    
    cleanup_existing
    pull_image
    run_container
    
    # Wait a moment for container to start
    sleep 5
    
    show_status
    
    echo ""
    echo "🎉 Deployment completed successfully!"
    echo "📖 Cloud Native Documentation is now running!"
}

# Run main function
main "$@"
