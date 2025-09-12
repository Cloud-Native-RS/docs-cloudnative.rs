# 🌐 Custom Domain Setup za docs.cloudnative.rs

## Koraci za podešavanje custom domena na Vercel

### 1. Dodavanje domena u Vercel

1. **Idite na Vercel dashboard** → vaš projekat
2. **Settings** → **Domains**
3. **Add Domain** → `docs.cloudnative.rs`
4. **Add**

### 2. DNS Konfiguracija

Vercel će vam dati instrukcije za DNS rekorde. Obično su to:

#### Opcija A: CNAME rekord (preporučeno)
```
Type: CNAME
Name: docs
Value: cname.vercel-dns.com
TTL: 300 (ili Auto)
```

#### Opcija B: A rekord
```
Type: A
Name: docs
Value: 76.76.19.61
TTL: 300 (ili Auto)
```

### 3. Dodavanje DNS rekorda

1. **Idite na vaš DNS provider** (gde ste kupili domen)
2. **Dodajte rekord** prema Vercel instrukcijama
3. **Sačuvajte promene**

### 4. Verifikacija

1. **U Vercel dashboard-u** ćete videti status domena
2. **Čekajte da se propagira** (5 minuta do 24h)
3. **Kada se pokaže "Valid"** - domen je aktivan

### 5. GitHub OAuth Ažuriranje

1. **Idite na:** https://github.com/settings/developers
2. **Kliknite na vašu OAuth aplikaciju**
3. **Ažurirajte Authorization callback URL:**
   ```
   https://docs.cloudnative.rs/api/auth/callback/github
   ```
4. **Update application**

### 6. Environment Variables Ažuriranje

U Vercel dashboard-u, ažurirajte:
```
NEXTAUTH_URL=https://docs.cloudnative.rs
```

## DNS Provider Instrukcije

### Cloudflare
1. **DNS** → **Records**
2. **Add record**
3. **Type:** CNAME
4. **Name:** docs
5. **Target:** cname.vercel-dns.com
6. **Proxy status:** DNS only (oranžni oblak)

### Namecheap
1. **Domain List** → **Manage**
2. **Advanced DNS**
3. **Add New Record**
4. **Type:** CNAME Record
5. **Host:** docs
6. **Value:** cname.vercel-dns.com

### GoDaddy
1. **My Products** → **DNS**
2. **Add Record**
3. **Type:** CNAME
4. **Name:** docs
5. **Value:** cname.vercel-dns.com

## Troubleshooting

### Domen se ne propagira
- **Proverite DNS rekorde** - možda su pogrešni
- **Čekajte duže** - ponekad treba do 48h
- **Kontaktirajte DNS provider** ako se nešto ne dešava

### SSL Certificate problemi
- **Vercel automatski izdaje SSL** za custom domene
- **Čekajte da se aktivira** (može potrajati)
- **Proverite da li je domen "Valid"** u Vercel dashboard-u

### GitHub OAuth ne radi
- **Proverite callback URL** u GitHub OAuth app
- **Možda treba da sačekate** da se DNS propagira
- **Testirajte sa vercel.app domenom** prvo

## Testiranje

```bash
# Proverite DNS propagaciju
nslookup docs.cloudnative.rs

# Proverite da li radi
curl -I https://docs.cloudnative.rs

# Proverite GitHub OAuth
curl -I https://docs.cloudnative.rs/api/auth/signin/github
```

## Finalni koraci

1. ✅ **Domen aktivan u Vercel**
2. ✅ **DNS rekordi dodati**
3. ✅ **GitHub OAuth callback ažuriran**
4. ✅ **Environment variables ažurirani**
5. ✅ **SSL certificate aktivan**

**Nakon ovoga, docs.cloudnative.rs će raditi potpuno!** 🎉
