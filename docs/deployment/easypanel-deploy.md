# EasyPanel Deployment Guide

## Option 1: Deploy from Docker Hub (Recommended)

### Step 1: Create New Service in EasyPanel
1. Login to your EasyPanel dashboard
2. Go to **Services** → **Create Service**
3. Choose **Docker Image**

### Step 2: Configure Docker Image
```
Image: darioristic/cloud-native-docs:latest
Container Port: 3000
Published Port: 8080
```

### Step 3: Environment Variables
Add these environment variables:
```
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1
```

### Step 4: Domain Configuration
- Set your domain or subdomain
- EasyPanel will handle SSL automatically

## Option 2: Deploy from GitHub Repository

### Step 1: Create New Service
1. Choose **GitHub Repository**
2. Connect your GitHub account
3. Select repository: `Cloud-Native-RS/docs-cloudnative.rs`

### Step 2: Build Configuration
```yaml
# Build settings
Build Command: docker build -t app .
Start Command: docker run -p 8080:3000 app
Container Port: 3000
Published Port: 8080
```

### Step 3: Environment Variables
```
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1
```

## Option 3: Custom Docker Image Upload

### Step 1: Export Docker Image
```bash
# Save Docker image to tar file
docker save cn-docs > cloud-native-docs.tar

# Compress for faster upload
gzip cloud-native-docs.tar
```

### Step 2: Upload via EasyPanel
1. Go to **Docker Images** in EasyPanel
2. Upload `cloud-native-docs.tar.gz`
3. Wait for import to complete

### Step 3: Create Service from Uploaded Image
1. Create new service
2. Select your uploaded image
3. Configure port 3000

## EasyPanel Docker Compose Configuration

If EasyPanel supports Docker Compose, use this configuration:

```yaml
version: '3.8'

services:
  cn-docs:
    image: darioristic/cloud-native-docs:latest
    ports:
      - "8080:3000"
    environment:
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## EasyPanel Service Configuration JSON

```json
{
  "name": "cloud-native-docs",
  "image": "darioristic/cloud-native-docs:latest",
  "ports": [
    {
      "published": 8080,
      "target": 3000,
      "protocol": "tcp"
    }
  ],
  "environment": {
    "NODE_ENV": "production",
    "NEXT_TELEMETRY_DISABLED": "1"
  },
  "restart": "unless-stopped",
  "healthcheck": {
    "test": ["CMD", "curl", "-f", "http://localhost:3000"],
    "interval": "30s",
    "timeout": "10s",
    "retries": 3
  }
}
```

## Resource Requirements for EasyPanel

### Minimum Requirements:
- **Memory**: 512MB RAM
- **CPU**: 0.5 vCPU
- **Storage**: 2GB
- **Port**: 8080 (avoid port 3000 conflict with EasyPanel)

### Recommended for Production:
- **Memory**: 1GB RAM
- **CPU**: 1 vCPU
- **Storage**: 5GB
- **Port**: 8080

## Custom Domain Configuration

### Step 1: Add Domain in EasyPanel
1. Go to your service settings
2. Add custom domain: `docs.your-domain.com`
3. EasyPanel will provide DNS settings

### Step 2: Update DNS Records
Add these DNS records to your domain:
```
Type: CNAME
Name: docs
Value: your-easypanel-subdomain.easypanel.host
```

## Environment-Specific Configurations

### Development Environment
```env
NODE_ENV=development
NEXT_TELEMETRY_DISABLED=1
```

### Staging Environment
```env
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1
STAGE=staging
```

### Production Environment
```env
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1
STAGE=production
```

## Monitoring and Logs

### View Application Logs
```bash
# In EasyPanel logs section, you'll see:
▲ Next.js ready
- Local:        http://localhost:3000
✓ Ready in 372ms
```

### Health Check Endpoint
```
GET http://your-domain.com:8080/
Status: 200 OK
```

### Port Configuration Note
**Important**: EasyPanel usually runs on port 3000, so we use port 8080 for our application to avoid conflicts:
- **Container Port**: 3000 (internal)
- **Published Port**: 8080 (external)
- **Access URL**: http://your-server-ip:8080

## Scaling Configuration

### Horizontal Scaling
```json
{
  "replicas": 2,
  "strategy": "rolling-update",
  "resources": {
    "memory": "1GB",
    "cpu": "1"
  }
}
```

## Backup and Updates

### Update Process
1. Push new changes to GitHub
2. EasyPanel auto-deploys if connected to repo
3. Or manually update Docker image:
   ```bash
   docker push darioristic/cloud-native-docs:latest
   ```
4. Restart service in EasyPanel

### Backup Configuration
- Enable automatic backups in EasyPanel
- Backup frequency: Daily
- Retention: 7 days

## Troubleshooting

### Common Issues:

1. **Port Conflicts**
   - Ensure port 3000 is configured correctly
   - Check EasyPanel port mapping

2. **Memory Issues**
   - Increase memory allocation to 1GB
   - Monitor resource usage

3. **SSL/Domain Issues**
   - Verify DNS propagation
   - Check EasyPanel SSL configuration

4. **Container Startup Issues**
   - Check application logs
   - Verify environment variables

### Debug Commands:
```bash
# Check if service is responding
curl -I http://your-server-ip:8080

# Check Docker container status
docker ps | grep cloud-native-docs

# View detailed logs
docker logs cloud-native-docs
```
