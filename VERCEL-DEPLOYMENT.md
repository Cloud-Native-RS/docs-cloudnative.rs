# 🚀 Vercel Deployment Guide

## Koraci za deployment na Vercel

### 1. Priprema GitHub repozitorija
```bash
# Commit sve promene
git add .
git commit -m "Prepare for Vercel deployment"
git push origin main
```

### 2. Vercel Setup

1. **Idite na:** https://vercel.com
2. **Sign in sa GitHub nalogom**
3. **Kliknite "New Project"**
4. **Importujte vaš GitHub repo:** `docs-cloudnative.rs-1`
5. **Framework:** Next.js (auto-detect)
6. **Root Directory:** `./` (default)

### 3. Environment Variables

U Vercel dashboard-u, idite na **Settings > Environment Variables** i dodajte:

```
NEXTAUTH_URL=https://docs.cloudnative.rs
NEXTAUTH_SECRET=lpoOS0yqIpGIzfmSQxzWAu4Ca4WatstrHjThptAzrbw=
GITHUB_ID=Ov23liUg8b4ewgeslN3t
GITHUB_SECRET=7d6e7c041a48f8b15400775bd289c8559c2f95ef
GITHUB_ORG=Cloud-Native-RS
NEXT_TELEMETRY_DISABLED=1
```

### 4. GitHub OAuth App Update

1. **Idite na:** https://github.com/settings/developers
2. **Kliknite na vašu OAuth aplikaciju**
3. **Ažurirajte Authorization callback URL:**
   ```
   https://docs.cloudnative.rs/api/auth/callback/github
   ```

### 5. Deploy

1. **Kliknite "Deploy" u Vercel**
2. **Čekajte da se završi build**
3. **Testirajte aplikaciju**

## Prednosti Vercel-a

✅ **Jednostavan deployment** - samo git push
✅ **Automatski HTTPS** - nema problema sa SSL
✅ **Edge functions** - brže odgovaranje
✅ **GitHub integracija** - automatski redeploy na push
✅ **Nema problema sa cookie-jima** - nativna Next.js podrška

## Custom Domain Setup

1. **U Vercel dashboard-u:** Settings > Domains
2. **Dodajte:** `docs.cloudnative.rs`
3. **Vercel će vam dati DNS rekorde** koje treba da dodate:
   ```
   Type: CNAME
   Name: docs
   Value: cname.vercel-dns.com
   
   Type: A
   Name: @
   Value: 76.76.19.61
   ```
4. **Dodajte DNS rekorde** u vašem DNS provider-u
5. **Čekajte da se propagira** (može potrajati do 24h)

## Troubleshooting

- **Build errors:** Proverite da li su svi dependencies u `package.json`
- **Environment variables:** Proverite da li su svi postavljeni u Vercel
- **GitHub OAuth:** Proverite callback URL u GitHub OAuth app

## Komande

```bash
# Lokalno testiranje
npm run dev

# Build test
npm run build
npm start

# Deploy na Vercel (preko Vercel CLI)
npx vercel --prod
```
