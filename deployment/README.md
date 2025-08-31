# Deployment

This folder contains all deployment-related files and documentation.

## Structure

- **scripts/** - Deployment and maintenance scripts
  - `deploy-*.sh` - Various deployment scripts (EasyPanel, OpenShift, Tekton)
  - `manual-deploy.sh` - Manual deployment script
  - `troubleshoot-cn-docs.sh` - Troubleshooting script
  - Health check and monitoring scripts

- **configs/** - Configuration files
  - `docker-compose*.yml` - Docker Compose configurations
  - `Dockerfile` - Container build configuration
  - `easypanel-config.json` - EasyPanel configuration

## Usage

1. Choose appropriate deployment method from the scripts
2. Configure environment using files in configs/
3. Refer to docs/deployment/ for detailed instructions
