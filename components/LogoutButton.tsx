import { signOut, useSession } from 'next-auth/react'
import { useRouter } from 'next/router'
import { useState } from 'react'
import { LogOut, User } from 'lucide-react'
import { Button } from './ui/button'

interface LogoutButtonProps {
  variant?: 'default' | 'outline' | 'ghost'
  size?: 'sm' | 'default' | 'lg'
  showUserInfo?: boolean
}

export default function LogoutButton({ 
  variant = 'outline', 
  size = 'default',
  showUserInfo = false 
}: LogoutButtonProps) {
  const { data: session } = useSession()
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)

  const handleLogout = async () => {
    setIsLoading(true)
    try {
      await signOut({ 
        callbackUrl: '/login',
        redirect: false 
      })
      router.push('/login')
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      setIsLoading(false)
    }
  }

  if (!session) {
    return null
  }

  if (showUserInfo) {
    return (
      <div className="flex items-center space-x-4">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-black rounded-full flex items-center justify-center">
            <User className="h-4 w-4 text-white" />
          </div>
          <div>
            <p className="text-sm font-medium text-black">{session.user?.name}</p>
            <p className="text-xs text-gray-500">{session.user?.email}</p>
          </div>
        </div>
        <Button
          onClick={handleLogout}
          disabled={isLoading}
          variant={variant}
          size={size}
          className="font-light border-gray-300 hover:border-black hover:bg-gray-50"
        >
          {isLoading ? (
            <>
              <div className="animate-spin rounded-full h-3 w-3 border-b-2 border-gray-600 mr-2"></div>
              Signing out...
            </>
          ) : (
            <>
              <LogOut className="mr-2 h-4 w-4" />
              Sign out
            </>
          )}
        </Button>
      </div>
    )
  }

  return (
    <Button
      onClick={handleLogout}
      disabled={isLoading}
      variant={variant}
      size={size}
      className="font-light border-gray-300 hover:border-black hover:bg-gray-50"
    >
      {isLoading ? (
        <>
          <div className="animate-spin rounded-full h-3 w-3 border-b-2 border-gray-600 mr-2"></div>
          Signing out...
        </>
      ) : (
        <>
          <LogOut className="mr-2 h-4 w-4" />
          Sign out
        </>
      )}
    </Button>
  )
}
