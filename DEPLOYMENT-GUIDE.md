# 🚀 Deployment Guide za docs.cloudnative.rs

Ovaj vodič će te provesti kroz proces deployment-a Cloud Native dokumentacije na `docs.cloudnative.rs` domen.

## 📋 Preduslovi

- VPS server sa Docker-om
- Domen `cloudnative.rs` konfigurisan u Cloudflare
- GitHub nalog sa pristupom `Cloud-Native-RS` organizaciji

## 🔧 Korak 1: Setup Environment Varijable

### 1.1 Kreiraj .env fajl na serveru

```bash
# Preuzmi setup skriptu
wget https://raw.githubusercontent.com/Cloud-Native-RS/docs-cloudnative.rs/main/deployment/scripts/setup-env.sh
chmod +x setup-env.sh
sudo ./setup-env.sh
```

### 1.2 Konfiguriši GitHub OAuth App

1. Idi na: https://github.com/settings/developers
2. Klikni "New OAuth App"
3. Popuni formu:
   - **Application name**: `Cloud Native Docs`
   - **Homepage URL**: `https://docs.cloudnative.rs`
   - **Authorization callback URL**: `https://docs.cloudnative.rs/api/auth/callback/github`
4. Klikni "Register application"
5. Kopiraj **Client ID** i **Client Secret**

### 1.3 Ažuriraj .env fajl

```bash
sudo nano /opt/cloud-native-docs/.env
```

Zameni sledeće vrednosti:
```env
GITHUB_ID=your-actual-github-client-id
GITHUB_SECRET=your-actual-github-client-secret
```

## 🐳 Korak 2: Deploy Aplikacije

### Opcija A: Standardni VPS Deployment

```bash
# Preuzmi deployment skriptu
wget https://raw.githubusercontent.com/Cloud-Native-RS/docs-cloudnative.rs/main/deployment/scripts/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

### Opcija B: EasyPanel Deployment

```bash
# Preuzmi EasyPanel deployment skriptu
wget https://raw.githubusercontent.com/Cloud-Native-RS/docs-cloudnative.rs/main/deployment/scripts/deploy-easypanel.sh
chmod +x deploy-easypanel.sh
sudo ./deploy-easypanel.sh
```

### Opcija C: Docker Compose

```bash
# Preuzmi docker-compose fajl
wget https://raw.githubusercontent.com/Cloud-Native-RS/docs-cloudnative.rs/main/deployment/configs/docker-compose.prod.yml

# Pokreni aplikaciju
docker-compose -f docker-compose.prod.yml up -d
```

## 🌐 Korak 3: Cloudflare DNS Setup

### 3.1 Dodaj DNS rekorde

U Cloudflare Dashboard-u:

1. Idi na **DNS** sekciju
2. Dodaj novi rekord:
   - **Type**: A
   - **Name**: `docs`
   - **IPv4 address**: `[tvoja-server-ip]`
   - **Proxy status**: ✅ Proxied (narandžasti oblak)
   - **TTL**: Auto

### 3.2 SSL/TLS konfiguracija

1. Idi na **SSL/TLS** sekciju
2. Postavi **Encryption mode** na "Full (strict)"
3. Uključi **Always Use HTTPS**
4. Uključi **HTTP Strict Transport Security (HSTS)**

### 3.3 Performance optimizacija

U **Speed** sekciji:
- ✅ Auto Minify: CSS, JavaScript, HTML
- ✅ Brotli compression
- ✅ Rocket Loader (opciono)

## ✅ Korak 4: Provera

### 4.1 Proveri da li aplikacija radi

```bash
# Proveri status kontejnera
docker ps --filter "name=cloud-native-docs"

# Proveri logove
docker logs cloud-native-docs

# Testiraj lokalno
curl -I http://localhost:80
```

### 4.2 Proveri DNS propagaciju

```bash
# Proveri DNS
nslookup docs.cloudnative.rs

# Proveri HTTPS
curl -I https://docs.cloudnative.rs
```

### 4.3 Testiraj GitHub autentifikaciju

1. Idi na: https://docs.cloudnative.rs
2. Klikni "Login"
3. Prijavi se sa GitHub nalogom
4. Proveri da li si uspešno ulogovan

## 🔧 Troubleshooting

### Problem: Aplikacija se ne pokreće

```bash
# Proveri logove
docker logs cloud-native-docs

# Proveri environment varijable
docker exec cloud-native-docs env | grep -E "(NEXTAUTH|GITHUB)"

# Restart kontejnera
docker restart cloud-native-docs
```

### Problem: GitHub autentifikacija ne radi

1. Proveri da li su GITHUB_ID i GITHUB_SECRET tačni
2. Proveri da li je callback URL tačan u GitHub OAuth App
3. Proveri da li je GITHUB_ORG tačan

### Problem: DNS ne radi

1. Proveri da li je DNS rekord tačan u Cloudflare
2. Sačekaj 24-48 sati za propagaciju
3. Proveri da li je server dostupan na portu 80/443

## 📞 Podrška

Ako imaš problema:

1. Proveri logove: `docker logs cloud-native-docs`
2. Otvori issue na GitHub: https://github.com/Cloud-Native-RS/docs-cloudnative.rs/issues
3. Kontaktiraj tim: [Cloud-Native-RS](https://github.com/Cloud-Native-RS)

## 🎉 Gotovo!

Aplikacija je sada dostupna na: **https://docs.cloudnative.rs**

---

**Napomene:**
- Environment fajl je sigurno postavljen u `/opt/cloud-native-docs/.env`
- Aplikacija automatski restart-uje sa serverom
- SSL sertifikat se automatski generiše kroz Cloudflare
- Backup environment fajla se kreira pre svake promene
