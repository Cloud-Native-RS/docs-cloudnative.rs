# Setup za Private Repository Authentication

## Problem
Sada kada je repository private (`https://github.com/Cloud-Native-RS/docs-cloudnative.rs`), pipeline ne može da pristupi kodu bez proper authentication.

## Rešenja

### Opcija 1: GitHub Personal Access Token (Preporučeno) 🔑

#### 1. Kreiraj GitHub Personal Access Token
1. Idi na GitHub: **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Klikni **Generate new token** → **Generate new token (classic)**
3. Dodeli naziv: `OpenShift Pipeline Access`
4. Scope permissions:
   - [x] `repo` (Full control of private repositories)
   - [x] `read:org` (Read org membership)
5. Kopiraj generated token (samo jednom će biti prikazan!)

#### 2. Kreiraj Secret u OpenShift
```bash
# Zameni YOUR_TOKEN sa stvarnim token-om
oc create secret generic github-auth-secret \
  --from-literal=username=git \
  --from-literal=password=YOUR_GITHUB_TOKEN \
  --type=kubernetes.io/basic-auth \
  -n cn-docs

# Dodaj annotation za Tekton
oc annotate secret github-auth-secret \
  tekton.dev/git-0=https://github.com \
  -n cn-docs
```

#### 3. Ažuriraj Service Account
```bash
# Kreiraj novi service account sa credentials
oc apply -f tekton/git-auth-secret.yaml

# Ili ažuriraj postojeći
oc patch serviceaccount cn-docs-pipeline-sa \
  -p '{"secrets":[{"name":"github-auth-secret"}]}' \
  -n cn-docs
```

### Opcija 2: SSH Key Authentication 🔐

#### 1. Generiši SSH Key Pair
```bash
# Generiši novi SSH key
ssh-keygen -t ed25519 -C "openshift-pipeline@cn-docs" -f ~/.ssh/openshift_pipeline_key

# Kopiraj public key
cat ~/.ssh/openshift_pipeline_key.pub
```

#### 2. Dodaj Public Key u GitHub
1. Idi na GitHub: **Settings** → **SSH and GPG keys**
2. Klikni **New SSH key**
3. Title: `OpenShift Pipeline`
4. Key type: `Authentication Key`
5. Paste public key content
6. Klikni **Add SSH key**

#### 3. Kreiraj SSH Secret u OpenShift
```bash
# Kreiraj secret sa private key
oc create secret generic github-ssh-secret \
  --from-file=ssh-privatekey=~/.ssh/openshift_pipeline_key \
  --from-literal=known_hosts="$(ssh-keyscan github.com)" \
  --type=kubernetes.io/ssh-auth \
  -n cn-docs

# Dodaj annotation
oc annotate secret github-ssh-secret \
  tekton.dev/git-0=git@github.com \
  -n cn-docs
```

#### 4. Ažuriraj Git URL za SSH
Za SSH authentication, promeni git URL u pipeline runs:
```yaml
# Umesto HTTPS
git-url: "https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git"

# Koristi SSH
git-url: "git@github.com:Cloud-Native-RS/docs-cloudnative.rs.git"
```

## Implementacija

### 1. Primeni Ažurirani Pipeline
```bash
# Primeni ažurirani pipeline sa auth support
oc apply -f tekton/pipeline.yaml
```

### 2. Test Authentication

#### Za Token Authentication:
```bash
# Test sa HTTPS i token
oc create -f - <<EOF
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: test-private-repo-token
  namespace: cn-docs
spec:
  pipelineRef:
    name: cn-docs-pipeline
  params:
    - name: git-url
      value: "https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git"
    - name: git-revision
      value: "main"
    - name: image-tag
      value: "test-private"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
  taskRunTemplate:
    serviceAccountName: cn-docs-pipeline-sa
EOF
```

#### Za SSH Authentication:
```bash
# Test sa SSH
oc create -f - <<EOF
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: test-private-repo-ssh
  namespace: cn-docs
spec:
  pipelineRef:
    name: cn-docs-pipeline
  params:
    - name: git-url
      value: "git@github.com:Cloud-Native-RS/docs-cloudnative.rs.git"
    - name: git-revision
      value: "main"
    - name: image-tag
      value: "test-ssh"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
  taskRunTemplate:
    serviceAccountName: cn-docs-pipeline-ssh-sa
EOF
```

### 3. Monitor Test Results
```bash
# Proverava logs
oc logs -f pipelinerun/test-private-repo-token
# ili
oc logs -f pipelinerun/test-private-repo-ssh

# Proverava status
oc get pipelinerun --sort-by=.metadata.creationTimestamp | tail -5
```

## Verifikacija

### Успešan Authentication:
```
Using Git credentials from service account
Cloning repository: https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git
Repository cloned successfully
Current branch: main
Last commit: <commit-hash> <commit-message>
```

### Neuspešan Authentication:
```
fatal: could not read Username for 'https://github.com': No such device or address
```

## Ažuriranje Postojećih Pipeline Runs

### Ažuriraj Default PipelineRun
```bash
# Ažuriraj postojeći pipelinerun da koristi authentication
oc patch pipelinerun cn-docs-pipeline-run-complete \
  --type='merge' \
  -p='{"spec":{"taskRunTemplate":{"serviceAccountName":"cn-docs-pipeline-sa"}}}'
```

### Ažuriraj Webhook Trigger
```bash
# Ažuriraj trigger template da koristi authentication
oc patch triggertemplate cn-docs-trigger-template \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/resourcetemplates/0/spec/taskRunTemplate", "value": {"serviceAccountName": "cn-docs-pipeline-sa"}}]'
```

## Security Best Practices

### Token Management:
- ✅ Koristiti tokens sa minimalnim permissions (samo `repo`)
- ✅ Redovno rotirati tokens (svake 3-6 meseci)
- ✅ Koristiti repository-specific tokens gde je moguće
- ✅ Monitor token usage u GitHub settings

### SSH Key Management:
- ✅ Koristiti ed25519 keys (sigurniji od RSA)
- ✅ Koristiti dedicated keys za automation
- ✅ Ne koristiti personal SSH keys za pipeline
- ✅ Redovno rotirati keys

### OpenShift Secrets:
- ✅ Ograničiti access na secrets (RBAC)
- ✅ Ne eksponirati secrets u logs
- ✅ Koristiti namespace-specific secrets
- ✅ Regular audit secret usage

## Troubleshooting

### Common Issues:

#### 1. "fatal: could not read Username"
- **Uzrok**: Credentials nisu properly attached
- **Rešenje**: Proveri service account i secret annotations

#### 2. "Permission denied (publickey)"
- **Uzrok**: SSH key nije properly configured
- **Rešenje**: Proveri SSH key u GitHub i secret content

#### 3. "Authentication failed"
- **Uzrok**: Token je expired ili nema permissions
- **Rešenje**: Regeneriši token sa proper scope

### Debug Commands:
```bash
# Proverava service account secrets
oc describe serviceaccount cn-docs-pipeline-sa

# Proverava secret content (bez revealing values)
oc describe secret github-auth-secret

# Proverava pipeline logs za auth issues
oc logs -f pipelinerun/your-pipeline-run --container=git-clone
```

## Preporučeni Setup

Za production environment, preporučujem **GitHub Personal Access Token** zbog:
- ✅ Lakša konfiguracija
- ✅ Centralized management u GitHub
- ✅ Easy rotation
- ✅ Detailed audit logs
- ✅ Granular permissions

SSH keys su bolji za development ili kada treba fine-grained access control.
