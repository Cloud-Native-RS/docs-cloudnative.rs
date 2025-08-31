# OpenShift Deployment Guide

Ovaj dokument opisuje kako deploy-ovati Cloud Native Documentation aplikaciju na OpenShift platformu.

## 🚀 Preduvjeti

### 1. OpenShift CLI (oc)
```bash
# macOS
brew install openshift-cli

# Linux
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xz
sudo mv oc /usr/local/bin/
```

### 2. Helm
```bash
# macOS
brew install helm

# Linux
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar -xz
sudo mv linux-amd64/helm /usr/local/bin/
```

### 3. Docker
```bash
# macOS
brew install --cask docker

# Linux
curl -fsSL https://get.docker.com | sh
```

## 🔐 OpenShift Autentifikacija

### 1. Login na OpenShift
```bash
# Koristi token iz OpenShift web konzole
oc login --token=<your-token> --server=<your-server>

# Ili koristi username/password
oc login -u <username> -p <password> --server=<your-server>
```

### 2. Proveri login
```bash
oc whoami
oc get projects
```

## 🏗️ Lokalni Build i Test

### 1. Build Docker image
```bash
# Build image
docker build -t cn-docs:latest .

# Test lokalno
docker run -p 3000:3000 cn-docs:latest
```

### 2. Test Helm chart
```bash
# Lint Helm chart
helm lint ./helm

# Dry run deployment
helm template cn-docs ./helm --namespace cn-docs
```

## 🚀 Deployment na OpenShift

### 1. Automatski deployment (preporučeno)
```bash
# Koristi deploy skriptu
chmod +x deploy-openshift.sh
./deploy-openshift.sh latest
```

### 2. Ručni deployment
```bash
# Kreiraj/izaberi projekat
oc new-project cn-docs --display-name="Cloud Native Documentation"

# Deploy sa Helm
helm upgrade --install cn-docs ./helm \
  --namespace cn-docs \
  --set image.tag=latest \
  --wait --timeout=10m
```

## 📊 Proveri Status

### 1. Proveri deployment
```bash
# Proveri podove
oc get pods -n cn-docs

# Proveri servise
oc get services -n cn-docs

# Proveri rute
oc get routes -n cn-docs
```

### 2. Proveri logove
```bash
# Pogledaj logove
oc logs -f deployment/cn-docs -n cn-docs

# Pogledaj events
oc get events -n cn-docs
```

## 🔧 Konfiguracija

### 1. Helm values
Glavne konfiguracije se nalaze u `helm/values.yaml`:

```yaml
# Replikacija
replicaCount: 2

# Resursi
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Autoscaling
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
```

### 2. Environment variables
```yaml
env:
  - name: NODE_ENV
    value: "production"
  - name: PORT
    value: "3000"
```

## 🌐 Pristup Aplikaciji

### 1. Preko OpenShift Route
```bash
# Proveri URL
oc get route cn-docs -n cn-docs -o jsonpath='{.spec.host}'

# Otvori u browser
open https://<route-url>
```

### 2. Port forwarding (za debugging)
```bash
# Port forward
oc port-forward svc/cn-docs 3000:3000 -n cn-docs

# Pristupi na localhost:3000
```

## 📈 Monitoring i Scaling

### 1. Horizontal Pod Autoscaler
```bash
# Proveri HPA status
oc get hpa -n cn-docs

# Ručno scale
oc scale deployment/cn-docs --replicas=5 -n cn-docs
```

### 2. Resursi
```bash
# Proveri resurse
oc top pods -n cn-docs
oc top nodes
```

## 🧹 Cleanup

### 1. Obriši deployment
```bash
# Obriši Helm release
helm uninstall cn-docs -n cn-docs

# Obriši projekat
oc delete project cn-docs
```

### 2. Obriši Docker image
```bash
docker rmi cn-docs:latest
```

## 🔍 Troubleshooting

### 1. Česti problemi

#### Pod ne može da startuje
```bash
# Proveri pod status
oc describe pod <pod-name> -n cn-docs

# Proveri logove
oc logs <pod-name> -n cn-docs
```

#### Image pull error
```bash
# Proveri image pull secrets
oc get secrets -n cn-docs

# Proveri image
oc get deployment cn-docs -n cn-docs -o yaml | grep image
```

#### Route ne radi
```bash
# Proveri route status
oc describe route cn-docs -n cn-docs

# Proveri service
oc get endpoints -n cn-docs
```

### 2. Debug komande
```bash
# Exec u pod
oc exec -it <pod-name> -n cn-docs -- /bin/sh

# Port forward
oc port-forward svc/cn-docs 3000:3000 -n cn-docs

# Proveri events
oc get events -n cn-docs --sort-by='.lastTimestamp'
```

## 📚 Korisni linkovi

- [OpenShift CLI Documentation](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Next.js Documentation](https://nextjs.org/docs)

## 🆘 Support

Za probleme sa deployment-om:

1. Proveri logove: `oc logs -f deployment/cn-docs -n cn-docs`
2. Proveri events: `oc get events -n cn-docs`
3. Proveri pod status: `oc describe pod <pod-name> -n cn-docs`
4. Proveri Helm status: `helm status cn-docs -n cn-docs`
