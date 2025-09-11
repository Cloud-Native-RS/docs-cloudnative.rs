import type { NextPage } from 'next'
import { signIn, getSession } from 'next-auth/react'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import { GithubIcon } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card'
import { Button } from '../components/ui/button'

const LoginPage: NextPage = () => {
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(false)

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
        router.push(`/auth/error?error=${result?.error || 'OAuthSignin'}`)
      }
    } catch (error) {
      console.error('Sign in error:', error)
      router.push('/auth/error?error=OAuthSignin')
    } finally {
      setIsLoading(false)
    }
  }

  const handleDemoSignIn = async () => {
    setIsLoading(true)
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
        router.push(`/auth/error?error=${result?.error || 'CredentialsSignin'}`)
      }
    } catch (error) {
      console.error('Demo sign in error:', error)
      router.push('/auth/error?error=CredentialsSignin')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <Card className="w-full md:w-[400px]">
        <CardHeader className="text-center">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-gray-100">
            <svg
              viewBox="0 0 144 144"
              fill="currentColor"
              stroke="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              strokeWidth="4"
              className="h-8 w-8 text-blue-600"
              aria-label="Cloud Native Logo"
              role="img"
            >
              <title>Cloud Native Logo</title>
              <path d="M108.411 31.0308L104.919 34.523C86.9284 52.5134 57.7601 52.5134 39.7697 34.523L36.2775 31.0308C34.8287 29.582 32.4797 29.582 31.0309 31.0308C29.5821 32.4796 29.5821 34.8286 31.0309 36.2773L34.5231 39.7695C52.5135 57.76 52.5135 86.9283 34.5231 104.919L31.0309 108.411C29.5821 109.86 29.5821 112.209 31.0309 113.657C32.4797 115.106 34.8287 115.106 36.2775 113.657L39.7697 110.165C57.7601 92.1748 86.9284 92.1748 104.919 110.165L108.411 113.657C109.86 115.106 112.209 115.106 113.658 113.657C115.106 112.209 115.106 109.86 113.658 108.411L110.165 104.919C92.1749 86.9283 92.1749 57.76 110.165 39.7695L113.658 36.2773C115.106 34.8286 115.106 32.4796 113.658 31.0308C112.209 29.582 109.86 29.582 108.411 31.0308Z" />
            </svg>
          </div>
          <CardTitle className="text-2xl">Welcome to Cloud Native Docs</CardTitle>
          <CardDescription>
            Sign in with your GitHub account to access the documentation
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <Button 
            onClick={handleGitHubSignIn}
            disabled={isLoading}
            className="w-full h-12 text-base"
            size="lg"
          >
            <GithubIcon className="mr-2 h-5 w-5" />
            {isLoading ? 'Signing in...' : 'Sign in with GitHub'}
          </Button>
          
          {process.env.NODE_ENV === 'development' && (
            <>
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <span className="w-full border-t" />
                </div>
                <div className="relative flex justify-center text-xs uppercase">
                  <span className="bg-background text-muted-foreground px-2">Or</span>
                </div>
              </div>
              
              <Button 
                onClick={handleDemoSignIn}
                disabled={isLoading}
                variant="outline"
                className="w-full h-12 text-base"
                size="lg"
              >
                {isLoading ? 'Signing in...' : 'Demo Login (Development Only)'}
              </Button>
            </>
          )}
          
          <div className="text-center">
            <p className="text-sm text-gray-600">
              {process.env.NODE_ENV === 'development' 
                ? 'Use Demo Login for testing, or set up GitHub OAuth for production.'
                : 'Access to this documentation is restricted to authorized users only.'
              }
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

export default LoginPage
