import type { NextApiRequest, NextApiResponse } from 'next'
import { getServerSession } from 'next-auth/next'
import NextAuth from 'next-auth'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' })
  }

  try {
    // Get the session to verify user is logged in
    const session = await getServerSession(req, res, {})
    
    if (!session) {
      return res.status(401).json({ message: 'Not authenticated' })
    }

    // Use NextAuth signOut to properly clear session
    await NextAuth.signOut(req, res, { callbackUrl: '/login' })

    // Return success response
    res.status(200).json({ success: true, message: 'Logged out successfully' })
  } catch (error) {
    console.error('Logout error:', error)
    res.status(500).json({ message: 'Internal server error' })
  }
}
