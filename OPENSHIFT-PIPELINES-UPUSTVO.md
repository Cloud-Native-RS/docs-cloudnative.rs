# 🚀 Kompletno Upustvo za OpenShift Pipelines (Tekton)

## 📋 Sadržaj

1. [Uvod u OpenShift Pipelines](#uvod)
2. [Instalacija i Podešavanje](#instalacija)
3. [Osnovni Koncepti](#koncepti)
4. [Kreiranje Pipeline-a](#kreiranje)
5. [Rešavanje Čestih Problema](#problemi)
6. [Best Practices](#best-practices)
7. [Primeri i Slučajevi Korišćenja](#primeri)
8. [Monitoring i Debugging](#monitoring)
9. [Integracija sa GitHub-om](#github)
10. [Napredne Funkcionalnosti](#napredne)

## 🎯 Uvod u OpenShift Pipelines {#uvod}

OpenShift Pipelines je **Kubernetes-nativno CI/CD rešenje** zasnovano na **Tekton projektu**. Omogućava kreiranje i izvršavanje CI/CD pipeline-a kao kontejnere koji se skaliraju po potrebi.

### ✨ Ključne Prednosti

- **Kubernetes-nativno**: Koristi standardne Kubernetes resurse
- **Serverless**: Nema potrebe za centralnim CI/CD serverom
- **Skalabilno**: Svaki korak se izvršava u sopstvenom kontejneru
- **Deklarativno**: Pipeline-i se definišu kao YAML fajlovi
- **Integrisano**: Ugrađeno u OpenShift konzolu

## 🔧 Instalacija i Podešavanje {#instalacija}

### 1. Instalacija OpenShift Pipelines Operatora

```bash
# Preko OpenShift konzole:
# 1. Idite na Operators > OperatorHub
# 2. Pretražite "OpenShift Pipelines"
# 3. Kliknite Install i pratite uputstva

# Ili preko CLI:
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: stable
  name: openshift-pipelines-operator-rh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

### 2. Verifikacija Instalacije

```bash
# Proverite da li su svi pod-ovi pokrenuti
oc get pods -n openshift-pipelines

# Proverite dostupne task-ove
oc get tasks -n openshift-pipelines
```

### 3. Kreiranje Project-a

```bash
# Kreirajte novi project za vaš pipeline
oc new-project my-app-cicd --display-name="My App CI/CD" --description="CI/CD pipeline for my application"
```

## 🧩 Osnovni Koncepti {#koncepti}

### Task
Osnovni blok za izvršavanje - definište jedan ili više koraka.

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello-world
spec:
  steps:
    - name: hello
      image: alpine:latest
      script: echo "Hello World!"
```

### Pipeline
Kolekcija task-ova koji se izvršavaju u određenom redosledu.

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: simple-pipeline
spec:
  tasks:
    - name: hello
      taskRef:
        name: hello-world
```

### PipelineRun
Instanca pipeline-a koja se izvršava.

```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: simple-pipeline-run
spec:
  pipelineRef:
    name: simple-pipeline
```

### Workspace
Deljeni prostor između task-ova za čuvanje fajlova.

### EventListener, TriggerTemplate, TriggerBinding
Omogućavaju automatsko pokretanje pipeline-a na osnovu spoljašnjih događaja (webhook-ovi).

## 🏗️ Kreiranje Pipeline-a {#kreiranje}

### 1. Osnovni Pipeline za NodeJS Aplikaciju

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: nodejs-app-pipeline
  namespace: my-app-cicd
spec:
  description: "CI/CD Pipeline for NodeJS Application"
  
  params:
    - name: git-url
      description: "Git repository URL"
      default: "https://github.com/your-org/your-app.git"
    - name: git-revision
      description: "Git revision to build"
      default: "main"
    - name: image-name
      description: "Container image name"
      default: "my-app"
    - name: image-tag
      description: "Container image tag"
      default: "latest"

  workspaces:
    - name: shared-workspace
      description: "Shared workspace for pipeline tasks"

  tasks:
    # 1. Git Clone
    - name: git-clone
      taskSpec:
        description: "Clone git repository"
        params:
          - name: url
            type: string
          - name: revision
            type: string
            default: "main"
        workspaces:
          - name: output
            description: "The git repo will be cloned here"
        steps:
          - name: clone
            image: alpine/git:latest
            workingDir: $(workspaces.output.path)
            script: |
              #!/bin/sh
              set -xe
              
              # Clean workspace
              rm -rf ./* .git || true
              
              # Clone repository
              git init
              git remote add origin $(params.url)
              git fetch origin $(params.revision)
              git checkout FETCH_HEAD
              
              echo "Repository cloned successfully"
              ls -la
      params:
        - name: url
          value: $(params.git-url)
        - name: revision
          value: $(params.git-revision)
      workspaces:
        - name: output
          workspace: shared-workspace

    # 2. Build Application
    - name: build-app
      runAfter: ["git-clone"]
      taskSpec:
        description: "Build NodeJS application"
        workspaces:
          - name: source
        steps:
          - name: install-and-build
            image: registry.access.redhat.com/ubi8/nodejs-18:latest
            workingDir: $(workspaces.source.path)
            script: |
              #!/bin/bash
              set -xe
              
              echo "Installing dependencies..."
              npm ci
              
              echo "Running tests..."
              npm test || echo "No tests found"
              
              echo "Building application..."
              npm run build
              
              echo "Build completed successfully"
      workspaces:
        - name: source
          workspace: shared-workspace

    # 3. Build Container Image
    - name: build-image
      runAfter: ["build-app"]
      taskSpec:
        description: "Build container image"
        params:
          - name: IMAGE
            type: string
        workspaces:
          - name: source
        steps:
          - name: build-and-push
            image: registry.redhat.io/rhel8/buildah:latest
            workingDir: $(workspaces.source.path)
            securityContext:
              privileged: true
            script: |
              #!/bin/bash
              set -xe
              
              echo "Building container image..."
              buildah build --tls-verify=false -t $(params.IMAGE) .
              
              echo "Pushing container image..."
              buildah push --tls-verify=false $(params.IMAGE)
              
              echo "Image built and pushed successfully"
      params:
        - name: IMAGE
          value: "image-registry.openshift-image-registry.svc:5000/$(context.pipelineRun.namespace)/$(params.image-name):$(params.image-tag)"
      workspaces:
        - name: source
          workspace: shared-workspace

    # 4. Deploy Application
    - name: deploy-app
      runAfter: ["build-image"]
      taskSpec:
        description: "Deploy application to OpenShift"
        params:
          - name: IMAGE
            type: string
          - name: APP_NAME
            type: string
        steps:
          - name: deploy
            image: registry.redhat.io/openshift4/ose-cli:latest
            script: |
              #!/bin/bash
              set -xe
              
              echo "Deploying application..."
              
              # Create or update deployment
              oc create deployment $(params.APP_NAME) --image=$(params.IMAGE) --dry-run=client -o yaml | oc apply -f -
              
              # Expose service
              oc expose deployment $(params.APP_NAME) --port=3000 --dry-run=client -o yaml | oc apply -f -
              
              # Create route
              oc expose service $(params.APP_NAME) --dry-run=client -o yaml | oc apply -f -
              
              # Wait for deployment to be ready
              oc rollout status deployment/$(params.APP_NAME) --timeout=300s
              
              echo "Deployment completed successfully!"
              oc get routes
      params:
        - name: IMAGE
          value: "image-registry.openshift-image-registry.svc:5000/$(context.pipelineRun.namespace)/$(params.image-name):$(params.image-tag)"
        - name: APP_NAME
          value: $(params.image-name)
```

### 2. RBAC Konfiguracija

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pipeline-service-account
  namespace: my-app-cicd

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pipeline-role
  namespace: my-app-cicd
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["route.openshift.io"]
    resources: ["routes"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["image.openshift.io"]
    resources: ["imagestreams", "imagestreamtags"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipeline-rolebinding
  namespace: my-app-cicd
subjects:
  - kind: ServiceAccount
    name: pipeline-service-account
    namespace: my-app-cicd
roleRef:
  kind: Role
  name: pipeline-role
  apiGroup: rbac.authorization.k8s.io
```

## 🔧 Rešavanje Čestih Problema {#problemi}

### Problem 1: Git Clone "Dubious Ownership" Greška

**Simptom:**
```
fatal: detected dubious ownership in repository at '/workspace/output'
```

**Rešenje:**
```yaml
script: |
  #!/bin/sh
  set -xe
  
  # Clean workspace
  rm -rf ./* .git || true
  
  # Clone using init + fetch approach
  git init
  git remote add origin $(params.url)
  git fetch origin $(params.revision)
  git checkout FETCH_HEAD
```

### Problem 2: Permission Denied Greške

**Simptom:**
```
mkdir /.docker: permission denied
```

**Rešenje:**
- Dodajte `securityContext` sa privileged pristupom za buildah task-ove
- Koristite odgovarajuće service account sa potrebnim dozvolama

### Problem 3: Task-ovi se ne pronalaze

**Simptom:**
```
tasks.tekton.dev "git-clone" not found
```

**Rešenje:**
- Koristite inline `taskSpec` umesto `taskRef` za custom task-ove
- Ili kopirajte potrebne task-ove iz `openshift-pipelines` namespace-a

### Problem 4: Workspace Mount Problemi

**Rešenje:**
```yaml
workspaces:
  - name: shared-workspace
    volumeClaimTemplate:
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
```

## 🎯 Best Practices {#best-practices}

### 1. Organizacija Resursa

```bash
# Grupisanje po aplikaciji
my-app-cicd/
├── pipelines/
│   ├── build-pipeline.yaml
│   ├── deploy-pipeline.yaml
│   └── test-pipeline.yaml
├── tasks/
│   ├── git-clone-task.yaml
│   ├── build-task.yaml
│   └── deploy-task.yaml
├── triggers/
│   ├── github-trigger.yaml
│   └── webhook-trigger.yaml
└── rbac/
    ├── service-account.yaml
    ├── role.yaml
    └── role-binding.yaml
```

### 2. Parametrizacija

```yaml
params:
  - name: git-url
    description: "Git repository URL"
    default: "https://github.com/org/repo.git"
  - name: image-tag
    description: "Image tag to build"
    default: "$(context.pipelineRun.name)"
  - name: deploy-environment
    description: "Deployment environment"
    default: "development"
```

### 3. Resource Limits

```yaml
steps:
  - name: build
    image: node:18
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "500m"
```

### 4. Error Handling

```yaml
script: |
  #!/bin/bash
  set -euo pipefail
  
  # Your script here
  npm test || {
    echo "Tests failed!"
    exit 1
  }
```

## 📊 Monitoring i Debugging {#monitoring}

### 1. Praćenje Pipeline Izvršavanja

```bash
# Liste svih pipeline run-ova
oc get pipelineruns

# Detalji o specifičnom run-u
oc describe pipelinerun my-pipeline-run

# Logovi iz task-a
oc logs -f pod/my-pipeline-run-task-pod

# Praćenje u realnom vremenu
tkn pipelinerun logs my-pipeline-run -f
```

### 2. Dashboard i Konzola

- **OpenShift Console**: Developer perspective > Pipelines
- **Tekton Dashboard**: Instalira se kao dodatni operator
- **CLI alati**: `tkn` (Tekton CLI)

### 3. Metrics i Alerting

```yaml
# ServiceMonitor za Prometheus
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: tekton-pipelines-metrics
spec:
  selector:
    matchLabels:
      app: tekton-pipelines-controller
  endpoints:
    - port: metrics
```

## 🔗 Integracija sa GitHub-om {#github}

### 1. EventListener Konfiguracija

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: github-listener
  namespace: my-app-cicd
spec:
  serviceAccountName: pipeline-service-account
  triggers:
    - name: github-push-trigger
      interceptors:
        - ref:
            name: "github"
          params:
            - name: "secretRef"
              value:
                secretName: github-webhook-secret
                secretKey: secretToken
            - name: "eventTypes"
              value: ["push"]
      bindings:
        - ref: github-push-binding
      template:
        ref: github-push-template
```

### 2. TriggerBinding

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerBinding
metadata:
  name: github-push-binding
  namespace: my-app-cicd
spec:
  params:
    - name: git-url
      value: $(body.repository.clone_url)
    - name: git-revision
      value: $(body.head_commit.id)
    - name: git-branch
      value: $(body.ref)
```

### 3. TriggerTemplate

```yaml
apiVersion: triggers.tekton.dev/v1alpha1
kind: TriggerTemplate
metadata:
  name: github-push-template
  namespace: my-app-cicd
spec:
  params:
    - name: git-url
    - name: git-revision
    - name: git-branch
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        name: github-pipeline-run-$(uid)
      spec:
        pipelineRef:
          name: nodejs-app-pipeline
        params:
          - name: git-url
            value: $(tt.params.git-url)
          - name: git-revision
            value: $(tt.params.git-revision)
        workspaces:
          - name: shared-workspace
            volumeClaimTemplate:
              spec:
                accessModes: [ReadWriteOnce]
                resources:
                  requests:
                    storage: 1Gi
```

### 4. GitHub Webhook Secret

```bash
# Kreirajte secret za GitHub webhook
oc create secret generic github-webhook-secret \
  --from-literal=secretToken=your-secret-token \
  -n my-app-cicd
```

### 5. GitHub Webhook URL

```bash
# Dobijte URL za webhook
oc get route el-github-listener -n my-app-cicd -o jsonpath='{.spec.host}'

# Konfigurišite u GitHub-u:
# Settings > Webhooks > Add webhook
# Payload URL: https://el-github-listener-my-app-cicd.apps.cluster.com
# Content type: application/json
# Secret: your-secret-token
# Events: Push events
```

## 🚀 Napredne Funkcionalnosti {#napredne}

### 1. Matrix Strategy (Parallel Builds)

```yaml
tasks:
  - name: test-matrix
    matrix:
      params:
        - name: node-version
          value: ["16", "18", "20"]
    taskSpec:
      params:
        - name: node-version
      steps:
        - name: test
          image: node:$(params.node-version)
          script: npm test
```

### 2. Conditional Tasks

```yaml
tasks:
  - name: deploy-prod
    when:
      - input: $(params.git-branch)
        operator: in
        values: ["refs/heads/main", "refs/heads/master"]
```

### 3. Custom Results

```yaml
taskSpec:
  results:
    - name: image-digest
      description: "Digest of the built image"
  steps:
    - name: build
      script: |
        buildah build -t myimage .
        buildah images --format "{{.Digest}}" myimage | tee $(results.image-digest.path)
```

### 4. Pipeline as Code

```yaml
# .tekton/pipeline.yaml u repository-ju
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: pac-pipeline
  annotations:
    pipelinesascode.tekton.dev/on-event: "[push, pull_request]"
    pipelinesascode.tekton.dev/on-target-branch: "[main]"
```

## 📝 Zaključak

OpenShift Pipelines pruža moćnu, skalabilnu i Kubernetes-nativnu platformu za CI/CD procese. Ključ uspeha je:

1. **Pravilno planiranje** - definišite jasno pipeline korake
2. **Testiranje postupno** - počnite sa jednostavnim pipeline-ovima
3. **Monitoring** - pratite performanse i greške
4. **Dokumentacija** - dokumentujte vaše pipeline-ove
5. **Sigurnost** - koristite odgovarajuće RBAC i secrets

### Korisni Linkovi

- [OpenShift Pipelines Dokumentacija](https://docs.openshift.com/container-platform/latest/cicd/pipelines/understanding-openshift-pipelines.html)
- [Tekton Dokumentacija](https://tekton.dev/docs/)
- [OpenShift Pipeline Primeri](https://github.com/openshift/pipelines-examples)
- [Tekton Hub](https://hub.tekton.dev/) - biblioteka task-ova

---

*Kreirao: OpenShift CI/CD Tim | Verzija: 1.0 | Datum: $(date)*
