import type { NextApiRequest, NextApiResponse } from 'next'
import { getServerSession } from 'next-auth/next'
import { getToken } from 'next-auth/jwt'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' })
  }

  try {
    // Get the session to verify user is logged in
    const session = await getServerSession(req, res, {})
    console.log('Server logout - session:', session)
    
    // Clear all NextAuth cookies
    const cookies = [
      'next-auth.session-token',
      'next-auth.csrf-token', 
      'next-auth.callback-url',
      'next-auth.state',
      'next-auth.pkce.code_verifier'
    ]
    
    // Set cookies to expire immediately
    const clearCookieHeaders = cookies.map(cookie => 
      `${cookie}=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; SameSite=Lax`
    )
    
    res.setHeader('Set-Cookie', clearCookieHeaders)
    
    console.log('Server logout - cookies cleared')
    
    // Redirect to login page
    res.redirect(302, '/login')
  } catch (error) {
    console.error('Server logout error:', error)
    res.redirect(302, '/login')
  }
}
