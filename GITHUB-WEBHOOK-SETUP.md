# GitHub Webhook Setup za OpenShift Pipelines

## Problem
Git push ne pokreće automatski OpenShift pipeline jer GitHub webhook nije konfigurisan.

## Rešenje - Konfiguracija GitHub Webhook-a

### 1. Otvori GitHub Repository Settings
1. Idi na: https://github.com/Cloud-Native-RS/docs-cloudnative.rs
2. Klikni na **Settings** tab
3. U levom meniju klikni na **Webhooks**
4. Klikni **Add webhook**

### 2. Konfiguracija Webhook-a

**Payload URL:**
```
http://el-cn-docs-event-listener-cn-docs.apps.ocp-5.datsci.softergee.si
```

**Content type:**
```
application/json
```

**Secret:**
```
your-github-webhook-secret-here
```

**Which events would you like to trigger this webhook?**
- [x] Just the push event

**Active:**
- [x] Active (checked)

### 3. Potvrdi Konfiguraciju
Klikni **Add webhook**

### 4. Test Webhook-a
1. Napravi malu promenu u kodu
2. Commit i push:
   ```bash
   git add .
   git commit -m "Test webhook"
   git push origin main
   ```
3. Proverava se da li se automatski pokrenuo pipeline:
   ```bash
   oc get pipelinerun --sort-by=.metadata.creationTimestamp | tail -5
   ```

## Verifikacija

### Ako Webhook Radi:
- Videćete novi PipelineRun sa imenom koji počinje sa `github-triggered-`
- U GitHub webhook page videćete zelenu checkmark za poslednji delivery

### Ako Webhook Ne Radi:
1. Proverite URL - mora biti tačan
2. Proverite secret - mora biti isti kao u OpenShift
3. Proverite Recent Deliveries u GitHub webhook settings

## Alternativa - Ručno Pokretanje

Ako ne možete da konfigurišete webhook, možete ručno pokretati pipeline:

```bash
# Kreiraj novi test run
oc create -f tekton/test-pipelinerun.yaml

# Ili kopiraj postojeći
oc get pipelinerun cn-docs-pipeline-run-post-commit -o yaml | \
  sed 's/cn-docs-pipeline-run-post-commit/cn-docs-pipeline-run-manual-'$(date +%s)'/g' | \
  oc apply -f -
```

## Current Status

✅ **Event Listener**: Aktivan i radi  
✅ **Webhook Endpoint**: Dostupan javno  
✅ **Secret**: Konfigurisan  
✅ **Pipeline**: Testiran i funkcionalan  
⚠️ **GitHub Webhook**: Treba da se konfigurirao ručno  

Kada konfigurirae webhook, svaki git push će automatski pokretati CI/CD pipeline!
