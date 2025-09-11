# 🚀 OpenShift Deployment Guide za docs.cloudnative.rs

Ovaj vodič će te provesti kroz proces deployment-a Cloud Native dokumentacije na OpenShift sa `docs.cloudnative.rs` domenom.

## 📋 Preduslovi

- OpenShift cluster sa pristupom
- OpenShift CLI (oc) instaliran
- Helm instaliran
- GitHub nalog sa pristupom `Cloud-Native-RS` organizaciji
- Cloudflare DNS konfigurisan

## 🔧 Korak 1: Priprema

### 1.1 Instaliraj potrebne alate

```bash
# OpenShift CLI
# Preuzmi sa: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 1.2 Prijavi se na OpenShift

```bash
oc login --token=<your-token> --server=<your-server>
```

### 1.3 Kloniraj repository

```bash
git clone https://github.com/Cloud-Native-RS/docs-cloudnative.rs.git
cd docs-cloudnative.rs
```

## 🐳 Korak 2: Deploy Aplikacije

### 2.1 Pokreni deployment skriptu

```bash
# Koristi novu deployment skriptu
./deployment/scripts/deploy-openshift-new.sh
```

Ova skripta će:
- Kreirati OpenShift projekt `cn-docs`
- Deployovati aplikaciju koristeći Helm
- Postaviti Route sa `docs.cloudnative.rs` domenom
- Pokrenuti health check

### 2.2 Proveri deployment status

```bash
# Proveri podove
oc get pods -n cn-docs

# Proveri servise
oc get services -n cn-docs

# Proveri rute
oc get routes -n cn-docs

# Proveri logove
oc logs -f deployment/cn-docs -n cn-docs
```

## 🔑 Korak 3: GitHub OAuth Setup

### 3.1 Kreiraj GitHub OAuth App

1. Idi na: https://github.com/settings/developers
2. Klikni "New OAuth App"
3. Popuni formu:
   - **Application name**: `Cloud Native Docs`
   - **Homepage URL**: `https://docs.cloudnative.rs`
   - **Authorization callback URL**: `https://docs.cloudnative.rs/api/auth/callback/github`
4. Klikni "Register application"
5. Kopiraj **Client ID** i **Client Secret**

### 3.2 Ažuriraj GitHub OAuth credentials

```bash
# Pokreni skriptu za ažuriranje credentials-a
./deployment/scripts/update-github-oauth.sh
```

Unesi GitHub Client ID i Secret kada te pita.

## 🌐 Korak 4: Cloudflare DNS Setup

### 4.1 Dodaj DNS rekorde

U Cloudflare Dashboard-u:

1. Idi na **DNS** sekciju
2. Dodaj novi rekord:
   - **Type**: CNAME
   - **Name**: `docs`
   - **Target**: `[openshift-route-url]`
   - **Proxy status**: ✅ Proxied (narandžasti oblak)
   - **TTL**: Auto

### 4.2 SSL/TLS konfiguracija

1. Idi na **SSL/TLS** sekciju
2. Postavi **Encryption mode** na "Full (strict)"
3. Uključi **Always Use HTTPS**
4. Uključi **HTTP Strict Transport Security (HSTS)**

## ✅ Korak 5: Provera

### 5.1 Proveri da li aplikacija radi

```bash
# Proveri status podova
oc get pods -n cn-docs

# Proveri logove
oc logs -f deployment/cn-docs -n cn-docs

# Testiraj aplikaciju
curl -I https://docs.cloudnative.rs
```

### 5.2 Testiraj GitHub autentifikaciju

1. Idi na: https://docs.cloudnative.rs
2. Klikni "Login"
3. Prijavi se sa GitHub nalogom
4. Proveri da li si uspešno ulogovan

## 🔧 Troubleshooting

### Problem: Podovi se ne pokreću

```bash
# Proveri logove
oc logs -f deployment/cn-docs -n cn-docs

# Proveri events
oc get events -n cn-docs

# Proveri pod detalje
oc describe pod <pod-name> -n cn-docs
```

### Problem: GitHub autentifikacija ne radi

1. Proveri da li su GITHUB_ID i GITHUB_SECRET tačni
2. Proveri da li je callback URL tačan u GitHub OAuth App
3. Proveri da li je GITHUB_ORG tačan

```bash
# Proveri environment varijable
oc get deployment cn-docs -n cn-docs -o yaml | grep -A 20 env:
```

### Problem: Route ne radi

```bash
# Proveri route
oc get route cn-docs -n cn-docs -o yaml

# Proveri DNS
nslookup docs.cloudnative.rs

# Proveri SSL sertifikat
openssl s_client -connect docs.cloudnative.rs:443 -servername docs.cloudnative.rs
```

## 📊 Monitoring i Maintenance

### 5.1 Proveri status aplikacije

```bash
# Proveri podove
oc get pods -n cn-docs

# Proveri resurse
oc top pods -n cn-docs

# Proveri logove
oc logs -f deployment/cn-docs -n cn-docs
```

### 5.2 Skaliranje aplikacije

```bash
# Povećaj broj replika
oc scale deployment/cn-docs --replicas=3 -n cn-docs

# Povećaj resurse
oc patch deployment cn-docs -n cn-docs -p '{"spec":{"template":{"spec":{"containers":[{"name":"cn-docs","resources":{"limits":{"cpu":"1000m","memory":"1Gi"}}}]}}}}'
```

### 5.3 Ažuriranje aplikacije

```bash
# Ažuriraj Docker image
./deployment/scripts/deploy-openshift-new.sh latest

# Ili koristi Helm direktno
helm upgrade cn-docs ./infrastructure/helm --namespace cn-docs --set image.tag=latest
```

## 🗑️ Cleanup

### 6.1 Obriši aplikaciju

```bash
# Obriši Helm release
helm uninstall cn-docs -n cn-docs

# Obriši projekt
oc delete project cn-docs
```

## 📞 Podrška

Ako imaš problema:

1. Proveri logove: `oc logs -f deployment/cn-docs -n cn-docs`
2. Otvori issue na GitHub: https://github.com/Cloud-Native-RS/docs-cloudnative.rs/issues
3. Kontaktiraj tim: [Cloud-Native-RS](https://github.com/Cloud-Native-RS)

## 🎉 Gotovo!

Aplikacija je sada dostupna na: **https://docs.cloudnative.rs**

---

**Napomene:**
- Aplikacija koristi `darioristic/cloud-native-docs:latest` Docker image
- Environment varijable su konfigurisane kroz Helm values
- Route je konfigurisan za `docs.cloudnative.rs` domen
- SSL sertifikat se automatski generiše kroz Cloudflare
- Aplikacija se automatski restart-uje kada se ažurira
