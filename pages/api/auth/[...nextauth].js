import NextAuth from 'next-auth'
import GithubProvider from 'next-auth/providers/github'

export default NextAuth({
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_ID,
      clientSecret: process.env.GITHUB_SECRET,
      authorization: {
        params: {
          scope: 'read:user user:email read:org',
        },
      },
    })
  ],
  callbacks: {
    async signIn({ user, account, profile }) {
      if (account.provider === 'github') {
        try {
          // Proverava da li je korisnik član Cloud Native organizacije
          const response = await fetch(
            `https://api.github.com/orgs/${process.env.GITHUB_ORG}/members/${profile.login}`,
            {
              headers: {
                Authorization: `token ${account.access_token}`,
                'User-Agent': 'CN-Docs-App',
              },
            }
          );
          
          // GitHub vraća 204 ako je korisnik član, 404 ako nije
          if (response.status === 204) {
            return true;
          } else {
            console.log(`Access denied for user ${profile.login}: not a member of ${process.env.GITHUB_ORG} organization`);
            return false;
          }
        } catch (error) {
          console.error('Error checking organization membership:', error);
          return false;
        }
      }
      return true;
    },
    async jwt({ token, account, profile }) {
      // Persist the OAuth access_token to the token right after signin
      if (account) {
        token.accessToken = account.access_token;
        token.githubLogin = profile?.login;
      }
      return token;
    },
    async session({ session, token }) {
      // Send properties to the client, like an access_token from a provider.
      session.accessToken = token.accessToken;
      session.githubLogin = token.githubLogin;
      return session;
    },
  },
  pages: {
    signIn: '/auth/signin',
    signOut: '/auth/signout',
    error: '/auth/error', // Error code passed in query string as ?error=
  },
  session: {
    strategy: 'jwt',
  },
  secret: process.env.NEXTAUTH_SECRET,
})
