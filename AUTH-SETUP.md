# 🔐 NextAuth.js Setup instrukcije

## 1. Kreiranje GitHub OAuth App

1. Idite na [GitHub Developer Settings](https://github.com/settings/developers)
2. Kliknite na **"New OAuth App"**
3. Popunite sledeće podatke:
   - **Application name**: `CN Docs Authentication`
   - **Homepage URL**: `http://localhost:3000` (za development)
   - **Authorization callback URL**: `http://localhost:3000/api/auth/callback/github`
4. Kliknite **"Register application"**
5. Sačuvajte **Client ID** i **Client Secret**

## 2. Environment varijable

1. Kreirajte `.env.local` fajl u root direktorijumu:
```bash
cp env.example .env.local
```

2. Popunite sledeće varijable u `.env.local`:
```env
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here  # Generirajte random string
GITHUB_ID=your-github-client-id
GITHUB_SECRET=your-github-client-secret
GITHUB_ORG=Cloud-Native-RS  # Vaša GitHub organizacija
```

## 3. Generisanje NEXTAUTH_SECRET

Možete koristiti bilo koji od sledećih načina:

```bash
# Opcija 1: OpenSSL
openssl rand -base64 32

# Opcija 2: Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Opcija 3: Online generator
# https://generate-secret.vercel.app/32
```

## 4. Production setup

Za production, promenite URL-ove u GitHub OAuth App-u:
- **Homepage URL**: `https://your-domain.com`
- **Authorization callback URL**: `https://your-domain.com/api/auth/callback/github`

I u `.env.local`:
```env
NEXTAUTH_URL=https://your-domain.com
```

## 5. Testiranje

1. Pokrenite aplikaciju:
```bash
npm run dev
```

2. Otvorite `http://localhost:3000`
3. Kliknite na **"Login with GitHub"** dugme u gornjem desnom uglu
4. Autentifikujte se sa GitHub nalogom
5. Trebalo bi da vidite svoje ime i **"Logout"** dugme

## 🎉 Gotovo!

Autentifikacija je sada aktivna. **Samo članovi vaše GitHub organizacije mogu da se loguju.**

### 🔒 Organizacijski pristup

- ✅ Automatska provera članstva u organizaciji
- ✅ Blokiranje pristupa za korisnike van organizacije  
- ✅ Sigurno korišćenje GitHub API-ja za validaciju
- ✅ Prilađena error stranica za odbačene korisnike

### ⚠️ Važne napomene za organizaciju

1. **Vidljivost članstva**: Da bi provera radila, članstvo u organizaciji mora biti **javno** ili aplikacija mora imati odgovarajuće dozvole.

2. **GitHub OAuth scope**: Aplikacija traži `read:org` dozvolu za čitanje organizacionih informacija.

3. **Privatne organizacije**: Ako je organizacija privatna, korisnici moraju da pokore članstvo javnim u svojim GitHub settings.

## Dodatne funkcionalnosti

### Dodatno ograničavanje na određene korisnike
Pored organizacionog pristupa, možete ograničiti na određene korisnike dodavanjem u `pages/api/auth/[...nextauth].js`:

```js
// U signIn callback funkciji, dodajte nakon provere organizacije:
const allowedUsers = ['username1', 'username2', 'username3']
if (!allowedUsers.includes(profile.login)) {
  console.log(`Access denied for user ${profile.login}: not in allowed users list`);
  return false;
}
```

### Zaštićene stranice
Da biste zaštitili određene stranice, koristite:

```js
import { useSession, getSession } from 'next-auth/react'
import { useRouter } from 'next/router'
import { useEffect } from 'react'

export default function ProtectedPage() {
  const { data: session, status } = useSession()
  const router = useRouter()

  useEffect(() => {
    if (status === 'loading') return // Still loading

    if (!session) {
      router.push('/api/auth/signin')
    }
  }, [session, status, router])

  if (status === 'loading') {
    return <div>Loading...</div>
  }

  if (!session) {
    return <div>Access Denied</div>
  }

  return (
    <div>
      <h1>Protected Content</h1>
      <p>Welcome, {session.user.name}!</p>
    </div>
  )
}
```
