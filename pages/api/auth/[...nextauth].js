import NextAuth from 'next-auth'
import GitHubProvider from 'next-auth/providers/github'
import CredentialsProvider from 'next-auth/providers/credentials'

export default NextAuth({
  debug: process.env.NODE_ENV === 'development',
  providers: [
    // Development credentials provider for testing
    ...(process.env.NODE_ENV === 'development' ? [
      CredentialsProvider({
        id: 'demo',
        name: 'Demo Login',
        credentials: {
          username: { label: 'Username', type: 'text', placeholder: 'demo' }
        },
        async authorize(credentials) {
          if (credentials?.username === 'demo') {
            return {
              id: '1',
              name: 'Demo User',
              email: 'demo@example.com',
              image: 'https://avatars.githubusercontent.com/u/1?v=4'
            }
          }
          return null
        }
      })
    ] : []),
    // GitHub provider for production
    GitHubProvider({
      clientId: process.env.GITHUB_ID || 'test-client-id',
      clientSecret: process.env.GITHUB_SECRET || 'test-client-secret',
      authorization: {
        params: {
          scope: 'read:user user:email read:org'
        }
      }
    })
  ],
  callbacks: {
    async signIn({ user, account }) {
      // Allow demo login in development
      if (account?.provider === 'demo') {
        return true
      }
      
      // Check organization membership for GitHub
      if (process.env.GITHUB_ORG && account?.provider === 'github' && account?.access_token) {
        try {
          console.log(`Checking organization membership for ${user.login} in ${process.env.GITHUB_ORG}`)
          const response = await fetch(`https://api.github.com/orgs/${process.env.GITHUB_ORG}/members/${user.login}`, {
            headers: {
              'Authorization': `Bearer ${account.access_token}`,
              'Accept': 'application/vnd.github.v3+json',
              'User-Agent': 'Cloud-Native-Docs'
            }
          })
          const isMember = response.ok
          console.log(`Organization membership check result: ${isMember}`)
          return isMember
        } catch (error) {
          console.error('Error checking organization membership:', error)
          return false
        }
      }
      return true
    },
    async jwt({ token, account }) {
      if (account) {
        token.accessToken = account.access_token
      }
      return token
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken
      return session
    }
  },
  pages: {
    signIn: '/login',
    error: '/auth/error'
  },
  session: {
    strategy: 'jwt'
  },
  secret: process.env.NEXTAUTH_SECRET
})