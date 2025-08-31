# 🔍 Route Health Check System

Automatski sistem za provjeru i popravku OpenShift route-a za CN-Docs aplikaciju.

## 📋 Komponente

### 1. `route-health-check.sh` - Glavni health check script
```bash
# Osnovna provjera i auto-fix
./scripts/route-health-check.sh check

# Samo testiranje route-a
./scripts/route-health-check.sh test

# Prisilno recreiranje route-a
./scripts/route-health-check.sh recreate
```

**Funkcionalnosti:**
- ✅ Testira route health (HTTP 200)
- ✅ Provjerava pod internal health
- ✅ Provjerava service endpoints
- ✅ Automatski recreira route ako je potrebno
- ✅ Retry logika sa eksponencijalnim backoff-om

### 2. `route-monitor.sh` - Kontinuirani monitoring
```bash
# Kontinuirani monitoring (svakih 5 minuta)
./scripts/route-monitor.sh monitor

# Jednokratna provjera
./scripts/route-monitor.sh once

# Test alert sistem
./scripts/route-monitor.sh test-alert
```

**Funkcionalnosti:**
- 📊 Kontinuirani monitoring
- 🚨 Email i Slack alerting
- 📝 Detaljno logovanje
- 🔄 Automatski recovery

### 3. `k8s/route-health-cronjob.yaml` - Kubernetes CronJob
```bash
# Deploy CronJob
oc apply -f k8s/route-health-cronjob.yaml

# Check CronJob status
oc get cronjobs -n cn-docs

# Check job history
oc get jobs -n cn-docs
```

**Funkcionalnosti:**
- ⏰ Scheduled checks (svakih 5 minuta)
- 🔐 Proper RBAC konfiguracija
- 📊 Job history tracking
- 🛡️ Security constraints

## 🚀 Setup i Konfiguracija

### 1. Basic Setup
```bash
# Omogući izvršavanje script-ova
chmod +x scripts/*.sh

# Set environment variables
export NAMESPACE=cn-docs
export APP_NAME=cn-docs
export ROUTE_HOSTNAME="cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si"
```

### 2. Deploy CronJob (preporučeno)
```bash
# Deploy automatski monitoring
oc apply -f k8s/route-health-cronjob.yaml

# Provjeri status
oc get cronjobs route-health-check -n cn-docs
```

### 3. Kontinuirani Monitoring
```bash
# Sa email alerting
export ALERT_EMAIL="admin@example.com"
export CHECK_INTERVAL=300  # 5 minuta

./scripts/route-monitor.sh monitor
```

### 4. Slack Integration
```bash
# Setup Slack webhook
export SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

./scripts/route-monitor.sh test-alert
```

## 🔧 Integracija sa Pipeline-om

Route health check je automatski integrisan u:

1. **Tekton Pipeline** - `verify-route` task
2. **Deploy Script** - `deploy-openshift.sh` 
3. **Manual Deploy** - `manual-deploy.sh`

## 📊 Monitoring i Alerting

### Log Files
```bash
# Health check logs
tail -f /tmp/route-monitor.log

# CronJob logs
oc logs job/route-health-check-<timestamp> -n cn-docs
```

### Metrics
```bash
# Check success rate
oc get jobs -n cn-docs -l component=route-monitor

# View recent executions
oc get events -n cn-docs --field-selector reason=SuccessfulCreate
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Permission Denied
```bash
# Check service account permissions
oc describe rolebinding cn-docs-route-monitor -n cn-docs

# Manual fix
oc apply -f k8s/route-health-cronjob.yaml
```

#### 2. Script Not Found
```bash
# Ensure scripts directory exists in the container
# For CronJob, script is downloaded from git repository
```

#### 3. Route Recreates Too Often
```bash
# Check if pods are actually healthy
oc get pods -l app=cn-docs -n cn-docs

# Review logs for root cause
oc logs deployment/cn-docs -n cn-docs
```

### Manual Recovery
```bash
# Emergency route fix
oc delete route cn-docs -n cn-docs
oc create route edge cn-docs \
  --service=cn-docs \
  --hostname=cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si \
  -n cn-docs

# Verify fix
curl -I https://cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si
```

## 🔄 Development

### Testing New Features
```bash
# Test script changes
./scripts/route-health-check.sh test

# Dry run monitoring
CHECK_INTERVAL=60 ./scripts/route-monitor.sh monitor
```

### Adding New Checks
Edit `scripts/route-health-check.sh` i dodaj nove funkcije:
```bash
# Example: SSL certificate check
check_ssl_certificate() {
    echo | openssl s_client -connect $ROUTE_HOSTNAME:443 2>/dev/null | openssl x509 -noout -dates
}
```

## 📈 Best Practices

1. **Monitoring Interval**: 5 minuta (optimalno između brzine i resource usage)
2. **Retry Logic**: 3 pokušaja sa 30s delay
3. **Alerting**: Pošalji alert tek nakon 3 consecutive failures
4. **Logging**: Sačuvaj sve aktivnosti za troubleshooting
5. **Security**: Koristi minimal RBAC permissions

## 🤝 Contributing

Za dodavanje novih funkcija:
1. Update `route-health-check.sh` script
2. Add tests za novu funkcionalnost  
3. Update pipeline task ako je potrebno
4. Update documentation
