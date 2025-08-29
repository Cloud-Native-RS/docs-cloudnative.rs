# VPS Deployment Guide

## Option 1: Using Docker Hub Registry

### Step 1: Tag and Push to Docker Hub
```bash
# Tag the image for Docker Hub
docker tag cn-docs yourusername/cloud-native-docs:latest

# Login to Docker Hub
docker login

# Push to Docker Hub
docker push yourusername/cloud-native-docs:latest
```

### Step 2: Deploy on VPS
```bash
# On your VPS, pull and run the image
docker pull yourusername/cloud-native-docs:latest
docker run -d -p 80:3000 --name cloud-native-docs yourusername/cloud-native-docs:latest
```

## Option 2: Direct File Transfer

### Step 1: Save Docker Image
```bash
# Save Docker image to tar file
docker save cn-docs > cloud-native-docs.tar
```

### Step 2: Transfer to VPS
```bash
# Transfer via SCP
scp cloud-native-docs.tar user@your-vps-ip:/home/user/

# Or use rsync
rsync -avz cloud-native-docs.tar user@your-vps-ip:/home/user/
```

### Step 3: Load and Run on VPS
```bash
# On VPS: Load the image
docker load < cloud-native-docs.tar

# Run the container
docker run -d -p 80:3000 --name cloud-native-docs cn-docs
```

## Option 3: Git Clone + Build on VPS

### Step 1: Clone Repository on VPS
```bash
# On VPS
git clone https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git
cd docs-cloudnative.rs
```

### Step 2: Build and Run
```bash
# Build Docker image on VPS
docker build -t cn-docs .

# Run the container
docker run -d -p 80:3000 --name cloud-native-docs cn-docs
```

## Production Docker Compose for VPS

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  cn-docs:
    image: yourusername/cloud-native-docs:latest
    ports:
      - "80:3000"
    environment:
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
    restart: unless-stopped
    container_name: cloud-native-docs
    networks:
      - cn-docs-network

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl/certs
    depends_on:
      - cn-docs
    restart: unless-stopped
    networks:
      - cn-docs-network

networks:
  cn-docs-network:
    driver: bridge
```

## Nginx Configuration (nginx.conf)

```nginx
events {
    worker_connections 1024;
}

http {
    upstream app {
        server cn-docs:3000;
    }

    server {
        listen 80;
        server_name your-domain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl;
        server_name your-domain.com;

        ssl_certificate /etc/ssl/certs/cert.pem;
        ssl_certificate_key /etc/ssl/certs/key.pem;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## VPS Requirements

- Docker installed
- At least 1GB RAM
- 10GB storage
- Open ports: 80, 443 (and 22 for SSH)

## Quick Commands for VPS Setup

```bash
# Install Docker on Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group (optional)
sudo usermod -aG docker $USER
```

## Monitoring Commands

```bash
# Check container status
docker ps

# View logs
docker logs cloud-native-docs

# Restart container
docker restart cloud-native-docs

# Update container
docker pull yourusername/cloud-native-docs:latest
docker stop cloud-native-docs
docker rm cloud-native-docs
docker run -d -p 80:3000 --name cloud-native-docs yourusername/cloud-native-docs:latest
```
