# GitHub Setup za CI/CD Pipeline

Ovaj dokument opisuje kako podešavati GitHub repository za automatizovani CI/CD pipeline.

## 🔐 GitHub Secrets

Za rad CI/CD pipeline-a potrebno je da podesiš sledeće secrets u GitHub repository:

### 1. Otvori GitHub Repository Settings
- Idi na tvoj repository na GitHub
- Klikni na **Settings** tab
- U levom meniju klikni na **Secrets and variables** → **Actions**

### 2. Dodaj potrebne Secrets

#### `OPENSHIFT_SERVER_URL`
```
Name: OPENSHIFT_SERVER_URL
Value: https://api.your-openshift-cluster.com:6443
```
**Primer:** `https://api.cluster-abc123.region.openshift.com:6443`

#### `OPENSHIFT_TOKEN`
```
Name: OPENSHIFT_TOKEN
Value: sha256~your-openshift-token-here
```
**Kako dobiti token:**
1. Login na OpenShift: `oc login`
2. Kopiraj token: `oc whoami -t`
3. Ili iz web konzole: User → Copy login command → Display Token

## 🚀 Aktivacija CI/CD Pipeline-a

### 1. Push u main branch
```bash
# Commit i push promene
git add .
git commit -m "Add CI/CD pipeline and OpenShift deployment"
git push origin main
```

### 2. Proveri GitHub Actions
- Idi na **Actions** tab u repository
- Trebalo bi da vidiš da se pokrenuo workflow "CI/CD Pipeline"

## 📋 Workflow Koraci

### 1. Test Job
- ✅ Checkout code
- ✅ Setup Node.js 18
- ✅ Install pnpm
- ✅ Install dependencies
- ✅ Run tests
- ✅ Build application

### 2. Build and Push Job
- ✅ Checkout code
- ✅ Setup Docker Buildx
- ✅ Login to GitHub Container Registry
- ✅ Build and push Docker image

### 3. Deploy to OpenShift Job
- ✅ Checkout code
- ✅ Setup OpenShift CLI
- ✅ Create/select project
- ✅ Deploy using Helm

## 🔍 Troubleshooting

### 1. Workflow neće da se pokrene
- Proveri da li je push u `main` ili `develop` branch
- Proveri da li je `.github/workflows/ci-cd.yml` fajl u repository

### 2. Build job ne uspeva
- Proveri da li `package.json` i `pnpm-lock.yaml` postoje
- Proveri da li `pnpm run build` radi lokalno

### 3. Docker build ne uspeva
- Proveri da li `Dockerfile` postoji
- Proveri da li Docker build radi lokalno: `docker build -t test .`

### 4. OpenShift deployment ne uspeva
- Proveri da li su `OPENSHIFT_SERVER_URL` i `OPENSHIFT_TOKEN` secrets podeseni
- Proveri da li OpenShift token ima dovoljno permisija
- Proveri da li OpenShift cluster ima dovoljno resursa

## 📊 Monitoring Deployment-a

### 1. GitHub Actions
- **Actions** tab → pogledaj workflow status
- **Packages** tab → pogledaj Docker image

### 2. OpenShift
```bash
# Login na OpenShift
oc login --token=<your-token> --server=<your-server>

# Proveri projekat
oc get projects | grep cn-docs

# Proveri deployment
oc get pods -n cn-docs
oc get routes -n cn-docs
```

## 🔧 Customizacija

### 1. Promeni branch trigger
U `.github/workflows/ci-cd.yml`:
```yaml
on:
  push:
    branches: [ main, develop, staging ]  # Dodaj staging
```

### 2. Dodaj environment-specific deployment
```yaml
deploy-to-openshift:
  environment: production  # Dodaj environment
  # ... ostali koraci
```

### 3. Promeni OpenShift project name
U workflow fajlu:
```yaml
oc new-project my-custom-name --display-name="My Custom App"
```

## 📚 Korisni linkovi

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [OpenShift CLI](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/)
- [Helm Documentation](https://helm.sh/docs/)

## 🆘 Support

Za probleme sa CI/CD pipeline-om:

1. **Proveri GitHub Actions logs** - Actions tab → klikni na workflow → klikni na job
2. **Proveri OpenShift status** - `oc get events -n cn-docs`
3. **Proveri Docker build** - `docker build -t test .`
4. **Proveri Helm chart** - `helm lint ./helm`
