import type { NextPage } from 'next'
import { signIn, getSession } from 'next-auth/react'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { GithubIcon, Mail, AlertCircle, Eye, EyeOff } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card'
import { Button } from '../components/ui/button'

const LoginPage: NextPage = () => {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)

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

  const handleGoogleSignIn = async () => {
    setIsLoading(true)
    setError(null)
    try {
      // For now, we'll just show an error since Google OAuth isn't configured
      setError('Google authentication is not yet configured. Please use GitHub login.')
    } catch (error) {
      console.error('Google sign in error:', error)
      setError('Google authentication failed. Please try again.')
    } finally {
      setIsLoading(false)
    }
  }

  const handleEmailSignIn = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)
    try {
      // For now, we'll just show an error since email authentication isn't configured
      setError('Email authentication is not yet configured. Please use GitHub login.')
    } catch (error) {
      console.error('Email sign in error:', error)
      setError('Email authentication failed. Please try again.')
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

  return (
    <div className="min-h-screen bg-black flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Login Card */}
        <div className="bg-gray-900 border border-gray-700 rounded-lg p-8">
          {/* Header */}
          <div className="text-center mb-8">
            <h1 className="text-2xl font-bold text-white mb-2">
              Login
            </h1>
            <p className="text-gray-400 text-sm">
              Enter your credentials to access your account
            </p>
          </div>

          {/* Error Message */}
          {error && (
            <div className="bg-red-900/20 border border-red-500/50 rounded-lg p-4 mb-6 flex items-start space-x-3">
              <AlertCircle className="h-5 w-5 text-red-400 mt-0.5 flex-shrink-0" />
              <div>
                <p className="text-sm font-medium text-red-400">Authentication Error</p>
                <p className="text-sm text-red-300 mt-1">{error}</p>
              </div>
            </div>
          )}

          {/* Social Login Buttons */}
          <div className="grid grid-cols-2 gap-3 mb-6">
            {/* Google Button */}
            <Button 
              onClick={handleGoogleSignIn}
              disabled={isLoading}
              className="h-12 bg-gray-800 hover:bg-gray-700 text-white border border-gray-600 hover:border-gray-500 transition-all duration-200"
            >
              <Mail className="mr-2 h-4 w-4" />
              Google
            </Button>

            {/* GitHub Button */}
            <Button 
              onClick={handleGitHubSignIn}
              disabled={isLoading}
              className="h-12 bg-gray-800 hover:bg-gray-700 text-white border border-gray-600 hover:border-gray-500 transition-all duration-200"
            >
              <GithubIcon className="mr-2 h-4 w-4" />
              GitHub
            </Button>
          </div>

          {/* Separator */}
          <div className="relative mb-6">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t border-gray-600" />
            </div>
            <div className="relative flex justify-center text-xs">
              <span className="bg-gray-900 text-gray-400 px-3 font-medium uppercase tracking-wide">
                OR CONTINUE WITH
              </span>
            </div>
          </div>

          {/* Email/Password Form */}
          <form onSubmit={handleEmailSignIn} className="space-y-4">
            {/* Email Field */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-white mb-2">
                Email
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your email"
                className="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                required
              />
            </div>

            {/* Password Field */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-white mb-2">
                Password
              </label>
              <div className="relative">
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  className="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 pr-12"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-white transition-colors duration-200"
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            {/* Login Button */}
            <Button 
              type="submit"
              disabled={isLoading}
              className="w-full h-12 bg-white text-gray-900 hover:bg-gray-100 font-medium transition-all duration-200"
            >
              {isLoading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-900 mr-3"></div>
                  Signing in...
                </>
              ) : (
                'Login with Email'
              )}
            </Button>
          </form>

          {/* Footer */}
          <div className="text-center mt-8 pt-6 border-t border-gray-700">
            <p className="text-xs text-gray-500">
              © 2025 Cloud Native RS. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default LoginPage