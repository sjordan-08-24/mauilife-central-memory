import { useState } from 'react'
import './LoginPage.css'

// Server URL - points to our Node.js auth server
const API_URL = 'http://localhost:3001'

/**
 * LoginPage Component
 *
 * Handles user login and registration.
 *
 * Props:
 * - onLogin: Function called when user successfully logs in, receives user data and token
 */
function LoginPage({ onLogin }) {
  // Toggle between login and register forms
  const [isRegistering, setIsRegistering] = useState(false)

  // Form fields
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [name, setName] = useState('')

  // Loading and error states
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      // Choose endpoint based on whether registering or logging in
      const endpoint = isRegistering ? '/auth/register' : '/auth/login'

      // Build request body
      const body = isRegistering
        ? { email, password, name }
        : { email, password }

      const response = await fetch(`${API_URL}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Something went wrong')
      }

      // Save token to localStorage so user stays logged in
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))

      // Call the onLogin callback with user data
      onLogin(data.user, data.token)

    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="login-page">
      <div className="login-card">
        <h1>{isRegistering ? 'Create Account' : 'Welcome Back'}</h1>
        <p className="subtitle">
          {isRegistering
            ? 'Sign up to get started'
            : 'Sign in to your account'}
        </p>

        {error && <div className="error-message">{error}</div>}

        <form onSubmit={handleSubmit}>
          {/* Name field only shown when registering */}
          {isRegistering && (
            <div className="form-group">
              <label htmlFor="name">Name</label>
              <input
                type="text"
                id="name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Your name"
              />
            </div>
          )}

          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Your password"
              required
            />
          </div>

          <button type="submit" className="submit-button" disabled={loading}>
            {loading
              ? 'Please wait...'
              : (isRegistering ? 'Create Account' : 'Sign In')}
          </button>
        </form>

        <div className="toggle-mode">
          {isRegistering ? (
            <p>
              Already have an account?{' '}
              <button
                type="button"
                className="link-button"
                onClick={() => setIsRegistering(false)}
              >
                Sign in
              </button>
            </p>
          ) : (
            <p>
              Don't have an account?{' '}
              <button
                type="button"
                className="link-button"
                onClick={() => setIsRegistering(true)}
              >
                Create one
              </button>
            </p>
          )}
        </div>
      </div>
    </div>
  )
}

export default LoginPage
