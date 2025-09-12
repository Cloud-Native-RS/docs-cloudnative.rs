import NextAuth from 'next-auth'
import GitHubProvider from 'next-auth/providers/github'
import CredentialsProvider from 'next-auth/providers/credentials'

export default NextAuth({
  providers: [
    GitHubProvider({
      clientId: process.env.GITHUB_ID,
      clientSecret: process.env.GITHUB_SECRET
    }),
    CredentialsProvider({
      name: 'credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' }
      },
      async authorize(credentials) {
        console.log('Credentials received:', credentials)
        
        // Simple demo credentials - replace with real authentication logic
        if (credentials.email === 'demo@cloudnative.rs' && credentials.password === 'demo123') {
          console.log('Demo user authenticated successfully')
          return {
            id: '1',
            name: 'Demo User',
            email: 'demo@cloudnative.rs',
            image: null
          }
        }
        
        // You can add more users here or connect to a database
        if (credentials.email === 'admin@cloudnative.rs' && credentials.password === 'admin123') {
          console.log('Admin user authenticated successfully')
          return {
            id: '2',
            name: 'Admin User',
            email: 'admin@cloudnative.rs',
            image: null
          }
        }
        
        console.log('Invalid credentials provided')
        return null
      }
    })
  ],
  callbacks: {
    async signIn({ user, account }) {
      // Allow all GitHub users and credentials users
      if (account?.provider === 'github') {
        console.log(`GitHub login successful for user: ${user.name}`)
        return true
      }
      if (account?.provider === 'credentials') {
        console.log(`Credentials login successful for user: ${user.name}`)
        return true
      }
      return true
    }
  },
  pages: {
    signIn: '/login',
    error: '/auth/error'
  },
  session: {
    strategy: 'jwt'
  },
  secret: process.env.NEXTAUTH_SECRET,
  debug: process.env.NODE_ENV === 'development'
})