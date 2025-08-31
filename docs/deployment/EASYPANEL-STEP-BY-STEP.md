# EasyPanel Deployment - Korak po Korak Uputstvo

## 🎯 Cilj
Deployment Cloud Native dokumentacije na EasyPanel server koristeći port 8080 (da izbegnemo konflikt sa EasyPanel admin panelom na portu 3000).

---

## 📋 Preduslovi

### 1. Priprema servera
- ✅ VPS/server sa instaliranim Docker-om
- ✅ EasyPanel instaliran i pokrenut
- ✅ Root ili sudo pristup serveru
- ✅ Otvoren port 8080 u firewall-u

### 2. Informacije koje ti trebaju
```
Server IP: ___________________
SSH pristup: ssh user@server-ip
EasyPanel URL: http://server-ip:3000
```

---

## 🚀 Metoda 1: Kroz EasyPanel Web Interface (Najlakše)

### Korak 1: Pristup EasyPanel Dashboard
```bash
# Otvori u browseru
http://YOUR-SERVER-IP:3000
```
- Uloguj se u EasyPanel admin panel
- Idi na **Services** tab

### Korak 2: Kreiraj novi servis
1. Klikni **"Create Service"**
2. Odaberi **"Docker Image"**
3. Unesi sledeće podatke:

```
Service Name: cloud-native-docs
Description: Cloud Native Documentation Site
```

### Korak 3: Konfiguriši Docker Image
```
Docker Image: darioristic/cloud-native-docs:latest
Container Port: 3000
Published Port: 8080
```

### Korak 4: Dodaj Environment Variables
Klikni **"Environment"** i dodaj:
```
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1
```

### Korak 5: Resursi (opciono)
```
Memory Limit: 1GB
CPU Limit: 1
```

### Korak 6: Deploy
1. Klikni **"Create Service"**
2. Sačekaj da se image download-uje
3. Servis će automatski startovati

### Korak 7: Proveri
```
URL: http://YOUR-SERVER-IP:8080
```
Sajt treba da bude dostupan na ovom URL-u.

---

## 🔧 Metoda 2: Automatski Script (Brže)

### Korak 1: SSH na server
```bash
ssh your-user@your-server-ip
```

### Korak 2: Download i pokreni script
```bash
# Download deployment script
wget https://raw.githubusercontent.com/Cloud-Native-RS/docs-cloudnative.rs/main/deploy-easypanel.sh

# Učini ga executable
chmod +x deploy-easypanel.sh

# Pokreni deployment
./deploy-easypanel.sh
```

### Korak 3: Proveri rezultat
Script će ispisati:
```
🎉 EasyPanel deployment completed successfully!
📖 Cloud Native Documentation is running on port 8080!
🌐 Application is available at: http://YOUR-SERVER-IP:8080
```

---

## 📦 Metoda 3: Manual Docker Commands

### Korak 1: SSH na server
```bash
ssh your-user@your-server-ip
```

### Korak 2: Pull Docker image
```bash
docker pull darioristic/cloud-native-docs:latest
```

### Korak 3: Stop postojeći kontejner (ako postoji)
```bash
docker stop cloud-native-docs 2>/dev/null || true
docker rm cloud-native-docs 2>/dev/null || true
```

### Korak 4: Pokreni novi kontejner
```bash
docker run -d \
  --name cloud-native-docs \
  -p 8080:3000 \
  --restart unless-stopped \
  -e NODE_ENV=production \
  -e NEXT_TELEMETRY_DISABLED=1 \
  darioristic/cloud-native-docs:latest
```

### Korak 5: Proveri status
```bash
docker ps | grep cloud-native-docs
```

---

## 🌐 Metoda 4: Docker Compose

### Korak 1: SSH na server
```bash
ssh your-user@your-server-ip
```

### Korak 2: Kreiraj docker-compose.yml
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  cloud-native-docs:
    image: darioristic/cloud-native-docs:latest
    container_name: cloud-native-docs
    ports:
      - "8080:3000"
    environment:
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF
```

### Korak 3: Pokreni sa Docker Compose
```bash
docker-compose up -d
```

### Korak 4: Proveri status
```bash
docker-compose ps
docker-compose logs
```

---

## 🔍 Verifikacija i Testiranje

### 1. Proveri da li kontejner radi
```bash
docker ps
```
Treba da vidiš kontejner sa statusom "Up"

### 2. Proveri logove
```bash
docker logs cloud-native-docs
```
Treba da vidiš:
```
▲ Next.js ready
- Local: http://localhost:3000
✓ Ready in 372ms
```

### 3. Test HTTP pristupa
```bash
curl -I http://localhost:8080
```
Treba da dobiješ `HTTP/1.1 200 OK`

### 4. Test u browseru
Otvori: `http://YOUR-SERVER-IP:8080`

---

## 🛠 Troubleshooting

### Problem 1: Port 8080 je zauzet
```bash
# Proveri šta koristi port 8080
sudo netstat -tulpn | grep :8080

# Zaustavi servis na portu 8080
sudo fuser -k 8080/tcp

# Ili koristi drugi port (npr. 8081)
docker run -d -p 8081:3000 --name cloud-native-docs darioristic/cloud-native-docs:latest
```

### Problem 2: Container se ne pokreće
```bash
# Proveri detaljne logove
docker logs cloud-native-docs

# Proveri da li image postoji
docker images | grep cloud-native-docs

# Pokreni u interactive mode za debug
docker run -it --rm darioristic/cloud-native-docs:latest /bin/sh
```

### Problem 3: Memory problemi
```bash
# Ograniči memory usage
docker run -d \
  --name cloud-native-docs \
  -p 8080:3000 \
  --memory="1g" \
  darioristic/cloud-native-docs:latest
```

### Problem 4: Firewall blokira port 8080
```bash
# Ubuntu/Debian
sudo ufw allow 8080

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Iptables
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
```

---

## 📊 Management Commands

### Start/Stop/Restart
```bash
# Stop
docker stop cloud-native-docs

# Start
docker start cloud-native-docs

# Restart
docker restart cloud-native-docs

# Remove
docker rm cloud-native-docs
```

### Update aplikacije
```bash
# Pull nova verzija
docker pull darioristic/cloud-native-docs:latest

# Stop stara verzija
docker stop cloud-native-docs
docker rm cloud-native-docs

# Pokreni novu verziju
docker run -d \
  --name cloud-native-docs \
  -p 8080:3000 \
  --restart unless-stopped \
  -e NODE_ENV=production \
  -e NEXT_TELEMETRY_DISABLED=1 \
  darioristic/cloud-native-docs:latest
```

### Backup i monitoring
```bash
# Export kontejnera
docker export cloud-native-docs > backup.tar

# Monitor resource usage
docker stats cloud-native-docs

# View real-time logs
docker logs -f cloud-native-docs
```

---

## ✅ Finalni checklist

- [ ] Server ima Docker instaliran
- [ ] EasyPanel radi na portu 3000
- [ ] Port 8080 je slobodan
- [ ] Firewall dozvoljava port 8080
- [ ] Image je pull-ovan: `darioristic/cloud-native-docs:latest`
- [ ] Kontejner je pokrenut sa mapiranjem `8080:3000`
- [ ] Environment variables su postavljene
- [ ] Aplikacija je dostupna na `http://SERVER-IP:8080`
- [ ] Health check prolazi
- [ ] Logovi pokazuju da je Next.js spreman

---

## 🎉 Uspešan Deployment

Ako si prošao kroz sve korake, tvoja Cloud Native dokumentacija treba da radi na:

```
🌐 URL: http://YOUR-SERVER-IP:8080
📊 EasyPanel: http://YOUR-SERVER-IP:3000
🐳 Container: cloud-native-docs
📦 Image: darioristic/cloud-native-docs:latest
```

**Čestitamo! 🎉 Dokumentacija je live!**
