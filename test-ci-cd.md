# 🧪 CI/CD Pipeline Test

Ovaj fajl je kreiran za testiranje CI/CD pipeline-a.

## 🚀 Test Scenarios

### 1. **GitHub Actions Trigger**
- [x] Push u main branch
- [x] Workflow pokretanje
- [x] Job execution

### 2. **Build Process**
- [x] Node.js setup
- [x] pnpm install
- [x] Next.js build
- [x] Docker build

### 3. **Deployment**
- [x] Helm chart validation
- [x] OpenShift deployment
- [x] Route creation

## 📊 Test Results

**Timestamp:** $(date)
**Branch:** main
**Commit:** $(git rev-parse --short HEAD)

## 🎯 Expected Outcome

1. **GitHub Actions** se pokreće automatski
2. **Test job** uspešno završava
3. **Build job** kreira Docker image
4. **Deploy job** deploy-uje na OpenShift

---

*Test fajl za CI/CD pipeline validaciju*
