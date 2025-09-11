# Cloud Native Documentation 📚

Comprehensive documentation for Cloud Native technologies, deployment strategies, operations, and sales resources with **automated CI/CD pipeline** for OpenShift deployment.

[![CI/CD Pipeline](https://github.com/Cloud-Native-RS/docs-cloudnative.rs/workflows/CI/CD%20Pipeline%20-%20Build%20and%20Deploy%20to%20OpenShift/badge.svg)](https://github.com/Cloud-Native-RS/docs-cloudnative.rs/actions)
[![Docker Image](https://img.shields.io/badge/Docker-Image-blue?logo=docker)](https://github.com/Cloud-Native-RS/docs-cloudnative.rs/packages)
[![OpenShift](https://img.shields.io/badge/OpenShift-Deployed-red?logo=redhat)](https://docs.cloudnative.rs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🌟 Features

### 🔐 **Secure Authentication**
- **GitHub OAuth** integration with NextAuth.js
- **Organization-based access control** for team members
- **Protected routes** - all content requires authentication
- **Session management** with automatic refresh
- **Secure login page** with modern UI

### 🚀 **CI/CD Pipeline**
- **Automated deployment** to OpenShift on every push to main branch
- **GitHub Actions** workflow for testing, building, and deployment
- **Docker containerization** with multi-stage builds
- **Helm charts** for Kubernetes/OpenShift deployment
- **Automatic scaling** with Horizontal Pod Autoscaler

### 📖 **Documentation**
- **Get Started** - Introduction to Cloud Native concepts and getting started guide
- **Deployment** - Deployment strategies, architecture, and best practices
- **Operations** - Cluster management, monitoring, and security
- **Resources** - Tools, scripts, documentation, and best practices
- **Troubleshooting** - Common issues and debugging procedures

### 🎯 **Projects & Sales**
- **Project EDU/POC** - Educational and Proof of Concept projects
- **Sales** - Business resources, services, and pricing models

### 🔗 **Useful Links**
- [Live Site](https://docs.cloudnative.rs) - Production deployment
- [Contact](https://cloud-native.rs/contact) - Contact information
- [GitHub](https://github.com/cloud-native-serbia) - Our GitHub repository
- [Kubernetes Docs](https://kubernetes.io/docs/) - Official Kubernetes documentation
- [OpenShift Docs](https://docs.openshift.com/) - Official OpenShift documentation

## 🛠 Technologies

- **Frontend:** Next.js 15 + Nextra Theme + MDX + TypeScript
- **Authentication:** NextAuth.js + GitHub OAuth
- **Styling:** TailwindCSS + CSS Modules
- **Containerization:** Docker + Multi-stage builds
- **Orchestration:** Kubernetes + OpenShift + Helm
- **CI/CD:** GitHub Actions + GitHub Container Registry
- **Deployment:** OpenShift Routes + Ingress + HTTPS

## 🚀 Quick Start

### 1. **Authentication Setup**
```bash
# Create GitHub OAuth App at: https://github.com/settings/developers
# Set callback URL: http://localhost:3000/api/auth/callback/github

# Copy environment variables
cp env.example .env.local

# Edit .env.local with your GitHub OAuth credentials
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here
GITHUB_ID=your-github-client-id
GITHUB_SECRET=your-github-client-secret
GITHUB_ORG=Cloud-Native-RS
```

### 2. **Local Development**
```bash
# Clone the repository
git clone https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git
cd docs-cloudnative.rs

# Install dependencies
pnpm install

# Start development server
pnpm dev
```

### 3. **Docker Local Testing**
```bash
# Build and run with Docker
docker-compose up --build

# Or manually
docker build -t cn-docs:latest .
docker run -p 3000:3000 cn-docs:latest
```

### 4. **OpenShift Deployment**
```bash
# Deploy to OpenShift with Helm
./deploy-openshift.sh latest

# Or manually with Helm
helm upgrade --install cn-docs ./helm --namespace cn-docs
```

### 5. **Tekton CI/CD Pipeline**
```bash
# Deploy Tekton pipeline to OpenShift
./deploy-tekton-pipeline.sh

# Run pipeline manually
oc apply -f tekton/pipelinerun.yaml

# Monitor pipeline
oc get pipelineruns -n cn-docs
```

## 🔄 CI/CD Pipeline

### **🚀 OpenShift Tekton Pipeline (Preporučeno)**
```mermaid
graph LR
    A[Git Push] --> B[GitHub Webhook]
    B --> C[OpenShift Tekton]
    C --> D[Fetch Repository]
    D --> E[Build Application]
    E --> F[Build Docker Image]
    F --> G[Push to Registry]
    G --> H[Deploy to OpenShift]
    H --> I[Run Tests]
    I --> J[Production Ready]
```

### **Pipeline Stages**
1. **🔍 Fetch Repository** - Git clone sa webhook trigger
2. **🏗️ Build Application** - Node.js build sa pnpm
3. **🐳 Build Docker Image** - Multi-stage Docker build sa Buildah
4. **📦 Push Image** - Push na OpenShift Image Registry
5. **🚀 Deploy OpenShift** - Helm-based deployment
6. **🧪 Run Tests** - Test execution i validacija
7. **🧹 Cleanup** - Workspace cleanup

### **Trigger Conditions**
- **Automatic:** Push to `main` branch (GitHub webhook)
- **Manual:** Pipeline run sa OpenShift CLI
- **Scheduled:** Cron-based triggers (konfigurabilno)

### **🔄 GitHub Actions Alternative**
```mermaid
graph LR
    A[Git Push] --> B[GitHub Actions]
    B --> C[Test & Build]
    C --> D[Docker Build]
    D --> E[Push to Registry]
    E --> F[Deploy to OpenShift]
    F --> G[Production Ready]
```

**Note:** GitHub Actions je i dalje dostupan kao alternativna opcija

## 🐳 Docker & Containerization

### **Multi-stage Dockerfile**
```dockerfile
# Optimized for production with:
# - Node.js 18 Alpine base
# - Multi-stage build process
# - Non-root user security
# - Standalone Next.js output
# - Minimal final image size
```

### **Local Docker Commands**
```bash
# Build image
docker build -t cn-docs:latest .

# Run container
docker run -p 3000:3000 cn-docs:latest

# View logs
docker logs <container-id>

# Stop container
docker stop <container-id>
```

## ☸️ OpenShift & Kubernetes

### **Helm Chart Features**
- **Security:** Non-root user, read-only filesystem
- **Scaling:** Horizontal Pod Autoscaler (2-10 replicas)
- **Networking:** OpenShift Routes + Ingress with HTTPS
- **Resources:** CPU/Memory limits and requests
- **Monitoring:** Health checks and readiness probes

### **Deployment Commands**
```bash
# Check OpenShift connection
oc whoami
oc get projects

# Deploy application
./deploy-openshift.sh latest

# Monitor deployment
oc get pods -n cn-docs
oc get routes -n cn-docs
oc logs -f deployment/cn-docs -n cn-docs
```

### **Production Features**
- **HTTPS:** Automatic SSL certificates with cert-manager
- **Load Balancing:** OpenShift Route with edge termination
- **Auto-scaling:** Based on CPU and memory usage
- **High Availability:** Multi-replica deployment across nodes

## 📁 Project Structure

```
cn-docs/
├── .github/workflows/      # GitHub Actions CI/CD (alternative)
│   └── ci-cd.yml          # GitHub Actions workflow
├── tekton/                 # OpenShift Tekton CI/CD pipeline
│   ├── pipeline.yaml      # Main pipeline definition
│   ├── pipelinerun.yaml   # Pipeline run template
│   ├── trigger.yaml       # Webhook triggers
│   └── rbac.yaml          # RBAC and ServiceAccounts
├── helm/                   # OpenShift/Kubernetes deployment
│   ├── Chart.yaml         # Helm chart metadata
│   ├── values.yaml        # Configuration values
│   └── templates/         # Kubernetes manifests
├── pages/                  # MDX pages and routing
│   ├── _meta.json         # Navigation configuration
│   ├── index.mdx          # Home page
│   ├── deployment/        # Deployment documentation
│   ├── operations/        # Operations documentation
│   ├── resources/         # Resources and tools
│   ├── projects/          # Projects (EDU/POC)
│   └── sales/            # Sales materials
├── components/            # React components
├── public/               # Static files (images, icons)
├── theme.config.tsx      # Nextra theme configuration
├── next.config.js        # Next.js configuration
├── Dockerfile            # Multi-stage Docker build
├── docker-compose.yml    # Local development setup
├── deploy-openshift.sh   # OpenShift deployment script
├── deploy-tekton-pipeline.sh # Tekton pipeline deployment
└── package.json          # Dependencies and scripts
```

## 🔧 Configuration

### **Environment Variables**
```bash
# Production
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1
PORT=3000
HOSTNAME=0.0.0.0

# Development
NODE_ENV=development
PORT=3000
```

### **Helm Values**
```yaml
# Customize deployment
replicaCount: 2
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

## 📝 Adding New Content

### **Creating a new page**
1. Create a new `.mdx` file in the appropriate directory under `pages/`
2. Update the `_meta.json` file to add the new page to navigation
3. Follow the existing content structure and formatting

### **Example _meta.json structure**
```json
{
  "index": "Overview",
  "new-page": "New Page",
  "subfolder": "Subfolder Name"
}
```

### **Adding separators and external links**
```json
{
  "---section": {
    "type": "separator", 
    "title": "Section Title"
  },
  "external-link": {
    "title": "External Link ↗",
    "href": "https://example.com",
    "newWindow": true
  }
}
```

## 🎨 Customization

- **Theme:** Modify `theme.config.tsx` for logo, title, footer, etc.
- **Styles:** Add custom CSS in the `components/` directory
- **Components:** Create reusable React components
- **Deployment:** Customize Helm values in `helm/values.yaml`
- **CI/CD:** Modify `.github/workflows/ci-cd.yml`

## 🚀 Deployment Options

### **1. Local Development**
```bash
pnpm dev          # Development server
pnpm build        # Production build
pnpm start        # Production server
```

### **2. Docker Local**
```bash
docker-compose up --build    # Build and run
docker-compose down          # Stop services
```

### **3. OpenShift Production**
```bash
./deploy-openshift.sh latest    # Automated deployment
```

### **4. Manual Kubernetes**
```bash
helm upgrade --install cn-docs ./helm --namespace cn-docs
```

### **5. Tekton Pipeline (Automated)**
```bash
# Deploy pipeline
./deploy-tekton-pipeline.sh

# Pipeline se pokreće automatski na Git push
# ili ručno sa:
oc apply -f tekton/pipelinerun.yaml
```

## 🔍 Monitoring & Troubleshooting

### **Health Checks**
```bash
# Pod status
oc get pods -n cn-docs

# Service endpoints
oc get endpoints -n cn-docs

# Route status
oc get routes -n cn-docs

# Events
oc get events -n cn-docs
```

### **Logs & Debugging**
```bash
# Application logs
oc logs -f deployment/cn-docs -n cn-docs

# Pod details
oc describe pod <pod-name> -n cn-docs

# Port forwarding for debugging
oc port-forward svc/cn-docs 3000:3000 -n cn-docs
```

### **Common Issues**
- **Build failures:** Check Docker build locally
- **Deployment issues:** Verify OpenShift permissions
- **Image pull errors:** Check container registry access
- **Route problems:** Verify DNS and SSL configuration

## 🤝 Contributing

### **Development Workflow**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Make your changes and test locally
4. Commit your changes (`git commit -am 'Add new feature'`)
5. Push to the branch (`git push origin feature/new-feature`)
6. Open a Pull Request

### **CI/CD Integration**
- All PRs automatically trigger CI/CD pipeline
- Automated testing and build verification
- Deployment previews available
- Production deployment on merge to main

## 📚 Documentation

- **[CI/CD Summary](CI-CD-SUMMARY.md)** - Complete pipeline overview
- **[OpenShift Deployment](OPENSHIFT-DEPLOYMENT.md)** - Detailed deployment guide
- **[Tekton Pipeline](TEKTON-PIPELINE.md)** - OpenShift Tekton CI/CD guide
- **[GitHub Setup](GITHUB-SETUP.md)** - GitHub Actions configuration
- **[Docker Compose](docker-compose.yml)** - Local development setup

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📞 Contact & Support

- **🌐 Website:** [cloud-native.rs](https://cloud-native.rs)
- **📚 Live Docs:** [docs.cloudnative.rs](https://docs.cloudnative.rs)
- **🐙 GitHub:** [cloud-native-serbia](https://github.com/cloud-native-serbia)
- **📧 Contact:** [Contact page](https://cloud-native.rs/contact)
- **🚀 CI/CD:** [GitHub Actions](https://github.com/Cloud-Native-RS/docs-cloudnative.rs/actions)

## 🎯 Roadmap

- [ ] **Multi-environment deployment** (dev, staging, prod)
- [ ] **Advanced monitoring** with Prometheus and Grafana
- [ ] **Blue-green deployment** strategies
- [ ] **Performance testing** integration
- [ ] **Security scanning** in CI/CD pipeline
- [ ] **Backup and disaster recovery** procedures

---

**Built with ❤️ for the Cloud Native community in Serbia**

*Powered by Next.js, Docker, OpenShift, and automated CI/CD pipeline*