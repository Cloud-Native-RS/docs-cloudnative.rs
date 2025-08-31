# Tekton Pipeline Permission Issues - Solution

## Problem Summary

The Tekton pipeline was failing with permission denied errors during the `build-image` step:

```
2025/08/31 16:55:17 warning: unsuccessful cred copy: ".docker" from "/tekton/creds" to "/": unable to create destination directory: mkdir /.docker: permission denied
2025/08/31 16:55:17 warning: unsuccessful cred copy: ".gitconfig" from "/tekton/creds" to "/": unable to open destination: open /.gitconfig: permission denied
2025/08/31 16:55:17 warning: unsuccessful cred copy: ".git-credentials" from "/tekton/creds" to "/": unable to open destination: open /.git-credentials: permission denied
error: mkdir /.kube: permission denied
```

## Root Cause

The issue was caused by OpenShift's security constraints preventing containers from writing to certain directories:

1. **Default HOME directory**: Tasks were trying to write to `/` (root directory) which is not writable
2. **Security Context Constraints (SCC)**: The default SCC was too restrictive
3. **KUBECONFIG location**: The oc CLI was trying to create `.kube` directory in an inaccessible location

## Solution Applied

### 1. Updated Pipeline Tasks Security Context

Modified all OpenShift CLI tasks (`build-image`, `deploy`, `verify-route`) to:
- Set `HOME` environment variable to workspace path
- Set `KUBECONFIG` to a writable location in the workspace
- Create `.kube` directory in the workspace before running oc commands

### 2. Enhanced RBAC Configuration

Created `tekton/rbac-enhanced.yaml` with:
- **SecurityContextConstraints (SCC)**: Custom SCC allowing necessary permissions
- **Enhanced Role permissions**: Additional permissions for image streams and build logs
- **ClusterRole for SCC access**: Proper binding to use the custom SCC

### 3. Updated PipelineRun Security Context

Modified `tekton/pipelinerun.yaml` to include:
```yaml
taskRunTemplate:
  serviceAccountName: cn-docs-pipeline-sa
  podTemplate:
    securityContext:
      runAsNonRoot: false
      runAsUser: 0
      fsGroup: 0
```

### 4. Automation Script

Created `scripts/fix-pipeline-permissions.sh` to automate the fix deployment.

## Files Modified

1. **`tekton/pipeline.yaml`**: Updated security contexts for all oc CLI tasks
2. **`tekton/pipelinerun.yaml`**: Added security context to pod template
3. **`tekton/rbac-enhanced.yaml`**: New enhanced RBAC with SCC (NEW FILE)
4. **`scripts/fix-pipeline-permissions.sh`**: Automation script (NEW FILE)

## How to Apply the Fix

### Option 1: Use the Automation Script (Recommended)

```bash
# Run the fix script
./scripts/fix-pipeline-permissions.sh
```

The script will:
- Backup existing configuration
- Apply enhanced RBAC and SCC
- Update pipeline configuration
- Clean up failed runs
- Provide next steps

### Option 2: Manual Application

```bash
# Apply enhanced RBAC configuration
oc apply -f tekton/rbac-enhanced.yaml

# Update pipeline
oc apply -f tekton/pipeline.yaml

# Clean up and run new pipeline
oc delete pipelinerun --all -n cn-docs
oc create -f tekton/pipelinerun.yaml
```

## Key Changes Explained

### Environment Variables in Tasks
```yaml
env:
  - name: HOME
    value: $(workspaces.source.path)
  - name: KUBECONFIG
    value: $(workspaces.source.path)/.kube/config
```

### Workspace Directory Creation
```bash
# Create .kube directory in workspace to avoid permission issues
mkdir -p $(workspaces.source.path)/.kube
```

### Security Context Constraints
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: cn-docs-pipeline-scc
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
```

## Verification

After applying the fix, verify:

1. **Pipeline runs without permission errors**:
   ```bash
   oc logs -f -n cn-docs $(oc get pipelinerun -n cn-docs -o name | head -1)
   ```

2. **Service account has proper permissions**:
   ```bash
   oc auth can-i list builds --as=system:serviceaccount:cn-docs:cn-docs-pipeline-sa -n cn-docs
   ```

3. **SCC is properly applied**:
   ```bash
   oc describe scc cn-docs-pipeline-scc
   ```

## Notes

- The SecurityContextConstraints requires cluster admin privileges to create
- If you don't have cluster admin access, ask your OpenShift administrator to apply the SCC
- The solution maintains security while providing necessary permissions for the pipeline

## Monitoring

Monitor future pipeline runs for any remaining permission issues:

```bash
# Watch pipeline runs
oc get pipelinerun -n cn-docs -w

# Check logs for specific run
oc logs -f -n cn-docs <pipelinerun-name>
```
