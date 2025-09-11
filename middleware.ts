import { withAuth } from 'next-auth/middleware'

export default withAuth(
  function middleware(req) {
    // This function runs after the token is verified
    return
  },
  {
    callbacks: {
      authorized: ({ token, req }) => {
        const { pathname } = req.nextUrl

        // Allow access to login page and auth pages
        if (pathname.startsWith('/login') ||
            pathname.startsWith('/auth/') ||
            pathname.startsWith('/api/auth/')) {
          return true
        }

        // Require authentication for all other pages
        return !!token
      },
    },
    pages: {
      signIn: '/login'
    }
  }
)

export const config = {
  matcher: [
    '/((?!api/auth|login|auth/|_next/static|_next/image|favicon.ico|public).*)',
  ],
}
