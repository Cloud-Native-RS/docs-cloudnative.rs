# Infrastructure

This folder contains Kubernetes and infrastructure configuration files.

## Structure

- **k8s/** - Kubernetes manifests
  - CronJobs, health checks
  - Basic Kubernetes resources

- **tekton/** - Tekton Pipelines configuration
  - Pipeline definitions
  - PipelineRun configurations
  - RBAC and security configurations
  - Triggers and automation

- **helm/** - Helm charts
  - Chart definitions
  - Templates for Kubernetes resources
  - Values files for configuration

## Usage

1. Use k8s/ for direct Kubernetes deployments
2. Use tekton/ for CI/CD pipeline setup
3. Use helm/ for templated Kubernetes deployments

Refer to docs/deployment/ for detailed setup instructions.
