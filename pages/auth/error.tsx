import type { NextPage } from 'next'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { AlertCircle, ArrowLeft, RefreshCw, Home, Shield, Clock } from 'lucide-react'
import { Button } from '../../components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../../components/ui/card'

const AuthErrorPage: NextPage = () => {
  const router = useRouter()
  const { error } = router.query
  const [countdown, setCountdown] = useState(5)

  useEffect(() => {
    // Countdown timer
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          router.push('/login')
          return 0
        }
        return prev - 1
      })
    }, 1000)

    return () => clearInterval(timer)
  }, [router])

  const getErrorMessage = (error: string | string[] | undefined) => {
    switch (error) {
      case 'Configuration':
        return {
          title: 'Server Configuration Error',
          message: 'There is a problem with the server configuration. Please contact support if this issue persists.',
          type: 'error'
        }
      case 'AccessDenied':
        return {
          title: 'Access Denied',
          message: 'You do not have permission to sign in. Please contact your administrator for access.',
          type: 'warning'
        }
      case 'Verification':
        return {
          title: 'Verification Failed',
          message: 'The verification token has expired or has already been used. Please try signing in again.',
          type: 'error'
        }
      case 'OAuthSignin':
        return {
          title: 'GitHub Sign-In Failed',
          message: 'There was an error during the GitHub sign-in process. Please check your connection and try again.',
          type: 'error'
        }
      case 'OAuthCallback':
        return {
          title: 'Authentication Callback Error',
          message: 'There was an error processing your authentication. Please try again.',
          type: 'error'
        }
      case 'OAuthCreateAccount':
        return {
          title: 'Account Creation Failed',
          message: 'Could not create your account. Please try again or contact support.',
          type: 'error'
        }
      case 'Callback':
        return {
          title: 'Authentication Error',
          message: 'There was an error during authentication. Please try again.',
          type: 'error'
        }
      case 'OAuthAccountNotLinked':
        return {
          title: 'Account Already Exists',
          message: 'An account with this email already exists with a different provider.',
          type: 'warning'
        }
      case 'CredentialsSignin':
        return {
          title: 'Sign-In Failed',
          message: 'The credentials you provided are incorrect. Please check and try again.',
          type: 'error'
        }
      case 'SessionRequired':
        return {
          title: 'Authentication Required',
          message: 'Please sign in to access this page.',
          type: 'info'
        }
      default:
        return {
          title: 'Authentication Error',
          message: 'An unexpected error occurred during authentication. Please try again.',
          type: 'error'
        }
    }
  }

  const getErrorIcon = (type: string) => {
    switch (type) {
      case 'warning':
        return <AlertCircle className="h-8 w-8 text-black" />
      case 'info':
        return <Shield className="h-8 w-8 text-black" />
      default:
        return <AlertCircle className="h-8 w-8 text-black" />
    }
  }

  const errorInfo = getErrorMessage(error)

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="mx-auto mb-8 flex h-20 w-20 items-center justify-center rounded-full bg-black">
            {getErrorIcon(errorInfo.type)}
          </div>
          <h1 className="text-3xl font-light text-black mb-3 tracking-tight">
            {errorInfo.title}
          </h1>
        </div>

        {/* Error Card */}
        <div className="bg-white border border-gray-200 rounded-lg p-8">
          {/* Error Message */}
          <div className="text-center mb-8">
            <p className="text-gray-700 leading-relaxed font-light">
              {errorInfo.message}
            </p>
          </div>

          {/* Countdown Timer */}
          <div className="bg-gray-50 rounded-lg p-4 text-center mb-6">
            <div className="flex items-center justify-center space-x-2 text-sm text-gray-600 font-light">
              <Clock className="h-4 w-4" />
              <span>Redirecting in</span>
              <span className="font-medium text-black">{countdown}</span>
              <span>second{countdown !== 1 ? 's' : ''}</span>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="space-y-3">
            <Button 
              onClick={() => router.push('/login')} 
              className="w-full h-12 bg-black hover:bg-gray-800 text-white font-light transition-colors duration-200"
            >
              <ArrowLeft className="mr-3 h-5 w-5" />
              Return to Login
            </Button>
            
            <Button 
              onClick={() => router.push('/')} 
              variant="outline"
              className="w-full h-10 border border-gray-300 hover:border-black hover:bg-gray-50 font-light"
            >
              <Home className="mr-3 h-4 w-4" />
              Go to Homepage
            </Button>
          </div>

          {/* Footer */}
          <div className="text-center mt-8 pt-6 border-t border-gray-100">
            <p className="text-xs text-gray-500 font-light">
              Contact support if the issue persists
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-12">
          <p className="text-xs text-gray-400 font-light">
            © 2025 Cloud Native RS
          </p>
        </div>
      </div>
    </div>
  )
}

export default AuthErrorPage