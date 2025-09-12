import type { NextPage } from 'next'
import { signIn, getSession } from 'next-auth/react'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { GithubIcon, Mail, AlertCircle, Eye, EyeOff } from 'lucide-react'

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

  const handleEmailSignIn = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)
    try {
      const result = await signIn('credentials', { 
        email,
        password,
        callbackUrl: '/',
        redirect: false 
      })
      
      console.log('Email sign in result:', result)
      
      if (result?.ok) {
        console.log('Email sign in successful, redirecting to home')
        router.push('/')
      } else {
        console.error('Email sign in failed:', result?.error)
        setError('Invalid email or password. Please try again.')
      }
    } catch (error) {
      console.error('Email sign in error:', error)
      setError('Authentication failed. Please try again.')
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
    <div className="min-h-screen bg-gray-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Header Logo */}
        <div className="text-center mb-8">
          <div className="flex items-center justify-center mb-2">
            <div className="w-8 h-8 bg-black rounded flex items-center justify-center mr-2">
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="w-5 h-5 text-white"
              >
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14,2 14,8 20,8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
                <polyline points="10,9 9,9 8,9"/>
              </svg>
            </div>
            <span className="text-xl font-semibold text-black">Cloud Native RS</span>
          </div>
        </div>

        {/* Login Card */}
        <div className="bg-white rounded-lg shadow-sm p-8">
          {/* Card Header */}
          <div className="text-center mb-8">
            <h1 className="text-2xl font-bold text-black mb-2">
              Welcome back
            </h1>
            <p className="text-gray-600 text-sm">
              Login with your GitHub account
            </p>
          </div>

          {/* Error Message */}
          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6 flex items-start space-x-3">
              <AlertCircle className="h-5 w-5 text-red-500 mt-0.5 flex-shrink-0" />
              <div>
                <p className="text-sm font-medium text-red-800">Authentication Error</p>
                <p className="text-sm text-red-700 mt-1">{error}</p>
              </div>
            </div>
          )}

          {/* GitHub Login Button */}
          <button 
            onClick={handleGitHubSignIn}
            disabled={isLoading}
            className="w-full h-12 bg-white border border-gray-300 rounded-lg text-black font-medium hover:bg-gray-50 transition-colors duration-200 flex items-center justify-center space-x-3 mb-6"
          >
            {isLoading ? (
              <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-black"></div>
            ) : (
              <>
                <GithubIcon className="h-5 w-5" />
                <span>Login with GitHub</span>
              </>
            )}
          </button>

          {/* Separator */}
          <div className="relative mb-6">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t border-gray-300" />
            </div>
            <div className="relative flex justify-center text-xs">
              <span className="bg-white text-gray-500 px-3 font-medium">
                Or continue with
              </span>
            </div>
          </div>

          {/* Email/Password Form */}
          <form onSubmit={handleEmailSignIn} className="space-y-4">
            {/* Email Field */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-black mb-2">
                Email
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="m@example.com"
                className="w-full px-4 py-3 bg-white border border-gray-300 rounded-lg text-black placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                required
              />
            </div>

            {/* Password Field */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <label htmlFor="password" className="block text-sm font-medium text-black">
                  Password
                </label>
                <a href="#" className="text-sm text-gray-600 hover:text-gray-800">
                  Forgot your password?
                </a>
              </div>
              <div className="relative">
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  className="w-full px-4 py-3 bg-white border border-gray-300 rounded-lg text-black placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 pr-12"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors duration-200"
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            {/* Login Button */}
            <button 
              type="submit"
              disabled={isLoading}
              className="w-full h-12 bg-black text-white rounded-lg font-medium hover:bg-gray-800 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mx-auto"></div>
              ) : (
                'Login'
              )}
            </button>
          </form>

          {/* Sign Up Link */}
          <div className="text-center mt-6">
            <p className="text-sm text-gray-600">
              Don't have an account?{' '}
              <a href="#" className="text-black hover:underline font-medium">
                Sign up
              </a>
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="text-center mt-8">
          <p className="text-xs text-gray-500">
            By clicking continue, you agree to our{' '}
            <a href="#" className="underline hover:text-gray-700">Terms of Service</a>
            {' '}and{' '}
            <a href="#" className="underline hover:text-gray-700">Privacy Policy</a>.
          </p>
        </div>
      </div>
    </div>
  )
}

export default LoginPage