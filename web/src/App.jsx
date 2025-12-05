import { useState } from 'react'
import './App.css'

function App() {
  const [message, setMessage] = useState('')
  const [loading, setLoading] = useState(false)

  // Example: Call an n8n webhook
  // Create a webhook in n8n, then paste the URL here
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

  return (
    <div className="app">
      <h1>My App</h1>

      <p>Edit <code>web/src/App.jsx</code> to get started.</p>

      <div className="card">
        <button onClick={callWebhook} disabled={loading}>
          {loading ? 'Loading...' : 'Call n8n Webhook'}
        </button>

        {message && (
          <pre className="response">{message}</pre>
        )}
      </div>
    </div>
  )
}

export default App
