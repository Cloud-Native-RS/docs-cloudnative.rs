import { useEffect } from 'react'
import { signOut } from 'next-auth/react'

export default function LogoutPage() {
  useEffect(() => {
    const performLogout = async () => {
      try {
        console.log('Performing logout...')
        
        // Sign out using NextAuth with redirect: false
        const result = await signOut({ 
          redirect: false,
          callbackUrl: '/login'
        })
        
        console.log('SignOut result:', result)
        
        // Clear all cookies manually as backup
        const cookies = document.cookie.split(';')
        for (let cookie of cookies) {
          const eqPos = cookie.indexOf('=')
          const name = eqPos > -1 ? cookie.substr(0, eqPos).trim() : cookie.trim()
          document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/;'
          document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/;domain=' + window.location.hostname + ';'
          document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/;domain=.' + window.location.hostname + ';'
        }
        
        // Clear storage
        localStorage.clear()
        sessionStorage.clear()
        
        console.log('Logout complete, redirecting to login...')
        
        // Force redirect to login
        window.location.replace('/login')
      } catch (error) {
        console.error('Logout error:', error)
        // Force redirect even on error
        window.location.replace('/login')
      }
    }

    performLogout()
  }, [])

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-black mx-auto mb-4"></div>
        <p className="text-gray-600">Signing out...</p>
      </div>
    </div>
  )
}
