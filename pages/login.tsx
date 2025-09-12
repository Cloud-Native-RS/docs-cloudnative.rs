import type { NextPage } from 'next'
import { signIn, getSession } from 'next-auth/react'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { GithubIcon, Lock, Shield, Users, ArrowRight, CheckCircle, AlertCircle } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card'
import { Button } from '../components/ui/button'

const LoginPage: NextPage = () => {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // Check if user is already logged in
    getSession().then((session) => {
      if (session) {
        console.log('User already logged in, redirecting to home')
        router.replace('/')
      }
    }).catch((error) => {
      console.error('Error checking session:', error)
    })
  }, [router])

  const handleGitHubSignIn = async () => {
    setIsLoading(true)
    setError(null)
    try {
      const result = await signIn('github', { 
        callbackUrl: '/',
        redirect: false 
      })
      
      console.log('GitHub sign in result:', result)
      
      if (result?.ok) {
        console.log('GitHub sign in successful, redirecting to home')
        router.push('/')
      } else {
        console.error('GitHub sign in failed:', result?.error)
        const errorMessage = getErrorMessage(result?.error || 'OAuthSignin')
        setError(errorMessage)
      }
    } catch (error) {
      console.error('Sign in error:', error)
      setError('An unexpected error occurred. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  const getErrorMessage = (error: string) => {
    switch (error) {
      case 'Configuration':
        return 'Server configuration error. Please contact support.'
      case 'AccessDenied':
        return 'Access denied. You do not have permission to sign in.'
      case 'Verification':
        return 'Verification token has expired. Please try again.'
      case 'OAuthSignin':
        return 'GitHub sign-in failed. Please check your connection and try again.'
      case 'OAuthCallback':
        return 'Authentication callback error. Please try again.'
      case 'OAuthCreateAccount':
        return 'Unable to create account. Please try again.'
      case 'Callback':
        return 'Authentication callback error. Please try again.'
      case 'OAuthAccountNotLinked':
        return 'Account already exists with different provider.'
      case 'SessionRequired':
        return 'Please sign in to access this page.'
      default:
        return 'Authentication failed. Please try again.'
    }
  }

  const handleDemoSignIn = async () => {
    setIsLoading(true)
    setError(null)
    try {
      const result = await signIn('demo', { 
        username: 'demo',
        callbackUrl: '/',
        redirect: false 
      })
      
      console.log('Demo sign in result:', result)
      
      if (result?.ok) {
        console.log('Demo sign in successful, redirecting to home')
        router.push('/')
      } else {
        console.error('Demo sign in failed:', result?.error)
        setError('Demo login failed. Please try again.')
      }
    } catch (error) {
      console.error('Demo sign in error:', error)
      setError('Demo login failed. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="mx-auto mb-8 flex h-20 w-20 items-center justify-center rounded-full bg-black">
            <svg
              viewBox="0 0 144 144"
              fill="currentColor"
              stroke="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              strokeWidth="4"
              className="h-12 w-12 text-white"
              aria-label="Cloud Native Logo"
              role="img"
            >
              <title>Cloud Native Logo</title>
              <path d="M108.411 31.0308L104.919 34.523C86.9284 52.5134 57.7601 52.5134 39.7697 34.523L36.2775 31.0308C34.8287 29.582 32.4797 29.582 31.0309 31.0308C29.5821 32.4796 29.5821 34.8286 31.0309 36.2773L34.5231 39.7695C52.5135 57.76 52.5135 86.9283 34.5231 104.919L31.0309 108.411C29.5821 109.86 29.5821 112.209 31.0309 113.657C32.4797 115.106 34.8287 115.106 36.2775 113.657L39.7697 110.165C57.7601 92.1748 86.9284 92.1748 104.919 110.165L108.411 113.657C109.86 115.106 112.209 115.106 113.658 113.657C115.106 112.209 115.106 109.86 113.658 108.411L110.165 104.919C92.1749 86.9283 92.1749 57.76 110.165 39.7695L113.658 36.2773C115.106 34.8286 115.106 32.4796 113.658 31.0308C112.209 29.582 109.86 29.582 108.411 31.0308Z" />
            </svg>
          </div>
          <h1 className="text-3xl font-light text-black mb-3 tracking-tight">
            Cloud Native Docs
          </h1>
          <p className="text-gray-600 font-light">
            Sign in to access documentation
          </p>
        </div>

        {/* Login Form */}
        <div className="bg-white border border-gray-200 rounded-lg shadow-sm p-8">
          {/* Error Message */}
          {error && (
            <div className="bg-gray-50 border-l-4 border-black rounded-lg p-4 mb-6 flex items-start space-x-3">
              <AlertCircle className="h-5 w-5 text-black mt-0.5 flex-shrink-0" />
              <div>
                <p className="text-sm font-medium text-black">Authentication Error</p>
                <p className="text-sm text-gray-700 mt-1">{error}</p>
              </div>
            </div>
          )}

          {/* GitHub Sign In */}
          <Button 
            onClick={handleGitHubSignIn}
            disabled={isLoading}
            className="w-full h-12 text-base font-medium bg-black hover:bg-gray-800 text-white border-0 transition-all duration-200 hover:shadow-md"
            size="lg"
          >
            {isLoading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-3"></div>
                Signing in...
              </>
            ) : (
              <>
                <GithubIcon className="mr-3 h-5 w-5" />
                Sign in with GitHub
                <ArrowRight className="ml-auto h-4 w-4" />
              </>
            )}
          </Button>

          {/* Development Demo Login */}
          {process.env.NODE_ENV === 'development' && (
            <>
              <div className="relative my-6">
                <div className="absolute inset-0 flex items-center">
                  <span className="w-full border-t border-gray-200" />
                </div>
                <div className="relative flex justify-center text-xs">
                  <span className="bg-white text-gray-500 px-3 font-light">or</span>
                </div>
              </div>
              
              <Button 
                onClick={handleDemoSignIn}
                disabled={isLoading}
                variant="outline"
                className="w-full h-10 text-sm font-medium border border-gray-300 hover:border-black hover:bg-gray-50 transition-colors duration-200"
              >
                {isLoading ? (
                  <>
                    <div className="animate-spin rounded-full h-3 w-3 border-b-2 border-gray-600 mr-3"></div>
                    Signing in...
                  </>
                ) : (
                  <>
                    <Users className="mr-3 h-4 w-4" />
                    Demo Login (Development Only)
                  </>
                )}
              </Button>
            </>
          )}

          {/* Features */}
          <div className="mt-8 pt-6 border-t border-gray-100">
            <div className="grid grid-cols-1 gap-3">
              <div className="flex items-center space-x-3 text-sm text-gray-600">
                <div className="w-2 h-2 bg-black rounded-full"></div>
                <span className="font-light">Secure GitHub authentication</span>
              </div>
              <div className="flex items-center space-x-3 text-sm text-gray-600">
                <div className="w-2 h-2 bg-black rounded-full"></div>
                <span className="font-light">Access to comprehensive documentation</span>
              </div>
              <div className="flex items-center space-x-3 text-sm text-gray-600">
                <div className="w-2 h-2 bg-black rounded-full"></div>
                <span className="font-light">Protected resources and guides</span>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="text-center mt-8 pt-6 border-t border-gray-100">
            <p className="text-xs text-gray-500 font-light">
              {process.env.NODE_ENV === 'development' 
                ? 'Development environment - Use demo login for testing'
                : 'Access restricted to authorized users only'
              }
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

export default LoginPage
