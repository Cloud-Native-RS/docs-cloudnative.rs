import { withAuth } from 'next-auth/middleware'
import { NextResponse } from 'next/server'
import type { NextRequestWithAuth } from 'next-auth/middleware'

console.log('Middleware file loaded')

export default withAuth(
  function middleware(req: NextRequestWithAuth) {
    const { pathname } = req.nextUrl
    const { token } = req.nextauth

    console.log('Middleware executing for:', pathname, 'token:', !!token)

    // Dozvoli pristup samo login stranicama i API rutama
    if (pathname.startsWith('/api/auth') || 
        pathname.startsWith('/login') ||
        pathname.startsWith('/_next') ||
        pathname.startsWith('/static') ||
        pathname === '/favicon.ico') {
      return NextResponse.next()
    }

    // Ako korisnik nije ulogovan, preusmeri na login
    if (!token) {
      console.log('Redirecting to /login')
      return NextResponse.redirect(new URL('/login', req.url))
    }

    return NextResponse.next()
  },
  {
    callbacks: {
      authorized: ({ token, req }) => {
        const { pathname } = req.nextUrl
        
        console.log('Authorized callback for:', pathname, 'token:', !!token)
        
        // Dozvoli pristup login stranicama i API rutama bez autentifikacije
        if (pathname.startsWith('/api/auth') || 
            pathname.startsWith('/login') ||
            pathname.startsWith('/_next') ||
            pathname.startsWith('/static') ||
            pathname === '/favicon.ico') {
          return true
        }
        
        // Za sve ostale stranice, zahtevaj autentifikaciju
        return !!token
      },
    },
  }
)

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api/auth (NextAuth API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - login (login page)
     */
    '/((?!api/auth|_next/static|_next/image|favicon.ico|login).*)',
  ]
}
