import { useRouter } from 'next/router'
import { useEffect } from 'react'

const errors = {
  Signin: 'Try signing in with a different account.',
  OAuthSignin: 'Try signing in with a different account.',
  OAuthCallback: 'Try signing in with a different account.',
  OAuthCreateAccount: 'Try signing in with a different account.',
  EmailCreateAccount: 'Try signing in with a different account.',
  Callback: 'Try signing in with a different account.',
  OAuthAccountNotLinked: 'To confirm your identity, sign in with the same account you used originally.',
  EmailSignin: 'Check your email address.',
  CredentialsSignin: 'Sign in failed. Check the details you provided are correct.',
  AccessDenied: 'You do not have permission to sign in. You must be a member of the Cloud Native organization.',
  Verification: 'The sign in link is no longer valid. It may have been used already or it may have expired.',
  default: 'Unable to sign in.',
}

export default function SignInError() {
  const router = useRouter()
  const { error } = router.query

  useEffect(() => {
    // Redirect to home after 5 seconds
    const timer = setTimeout(() => {
      router.push('/')
    }, 5000)

    return () => clearTimeout(timer)
  }, [router])

  const errorMessage = error && typeof error === 'string' ? errors[error as keyof typeof errors] ?? errors.default : errors.default

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      padding: '20px',
      textAlign: 'center',
      fontFamily: 'system-ui, sans-serif'
    }}>
      <div style={{
        maxWidth: '400px',
        padding: '40px',
        backgroundColor: '#fef2f2',
        border: '1px solid #fecaca',
        borderRadius: '8px',
        boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)'
      }}>
        <h1 style={{ 
          color: '#dc2626', 
          marginBottom: '16px',
          fontSize: '24px',
          fontWeight: '600'
        }}>
          Authentication Error
        </h1>
        
        <p style={{ 
          color: '#374151', 
          marginBottom: '24px',
          lineHeight: '1.5'
        }}>
          {errorMessage}
        </p>

        {error === 'AccessDenied' && (
          <div style={{
            padding: '16px',
            backgroundColor: '#fff3cd',
            border: '1px solid #ffeaa7',
            borderRadius: '6px',
            marginBottom: '20px'
          }}>
            <p style={{ 
              color: '#856404',
              margin: 0,
              fontSize: '14px'
            }}>
              <strong>Note:</strong> Only members of the Cloud Native GitHub organization can access this documentation.
            </p>
          </div>
        )}
        
        <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
          <button
            onClick={() => router.push('/api/auth/signin')}
            style={{
              padding: '8px 16px',
              backgroundColor: '#3b82f6',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              fontSize: '14px'
            }}
          >
            Try Again
          </button>
          
          <button
            onClick={() => router.push('/')}
            style={{
              padding: '8px 16px',
              backgroundColor: '#6b7280',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              fontSize: '14px'
            }}
          >
            Go Home
          </button>
        </div>
        
        <p style={{ 
          color: '#6b7280', 
          fontSize: '12px',
          marginTop: '20px',
          marginBottom: 0
        }}>
          Redirecting to home page in 5 seconds...
        </p>
      </div>
    </div>
  )
}
