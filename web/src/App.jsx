import { useState, useEffect } from 'react'
import './App.css'
import Button from './components/button/button'
import LoginPage from './components/LoginPage/LoginPage'

function App() {
  // Auth state - stores the logged-in user and their token
  const [user, setUser] = useState(null)
  const [token, setToken] = useState(null)

  // App state
  const [message, setMessage] = useState('')
  const [loading, setLoading] = useState(false)

  // Check if user is already logged in when app loads
  useEffect(() => {
    const savedToken = localStorage.getItem('token')
    const savedUser = localStorage.getItem('user')

    if (savedToken && savedUser) {
      setToken(savedToken)
      setUser(JSON.parse(savedUser))
    }
  }, [])

  // Called when user successfully logs in
  const handleLogin = (userData, userToken) => {
    setUser(userData)
    setToken(userToken)
  }

  // Log out the user
  const handleLogout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    setUser(null)
    setToken(null)
  }

  // Example: Call an n8n webhook
  const callWebhook = async () => {
    setLoading(true)
    try {
      const response = await fetch('http://localhost:5678/webhook/your-webhook-path', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ hello: 'world' }),
      })
      const data = await response.json()
      setMessage(JSON.stringify(data, null, 2))
    } catch (error) {
      setMessage('Error: ' + error.message)
    }
    setLoading(false)
  }

  // Call the test webhook
  const callTestWebhook = async () => {
    setLoading(true)
    try {
      const response = await fetch('http://localhost:5678/webhook-test/claude-test', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ hello: 'world' }),
      })
      const data = await response.json()
      setMessage(JSON.stringify(data, null, 2))
    } catch (error) {
      setMessage('Error: ' + error.message)
    }
    setLoading(false)
  }

  // If user is not logged in, show the login page
  if (!user) {
    return <LoginPage onLogin={handleLogin} />
  }

  // User is logged in - show the main app
  return (
    <div className="app">
      {/* Header with user info and logout */}
      <div className="header">
        <span>Welcome, {user.name || user.email}!</span>
        <Button onClick={handleLogout} variant="secondary">
          Logout
        </Button>
      </div>

      <h1>My App</h1>

      <p>Edit <code>web/src/App.jsx</code> to get started.</p>

      <div className="card">
        <Button onClick={callWebhook} loading={loading}>
          Call n8n Webhook
        </Button>

        <Button onClick={callTestWebhook} loading={loading} variant="secondary">
          Test Webhook
        </Button>

        {message && (
          <pre className="response">{message}</pre>
        )}
      </div>
    </div>
  )
}

export default App
