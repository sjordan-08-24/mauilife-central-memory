# Project Context

This is a local development stack for building web applications with workflow automation and AI capabilities.

## Stack Overview

- **React frontend** (`./web`) - Vite + React app with hot reloading on port 3000
- **n8n** - Workflow automation on port 5678, used to build backend logic without code
- **Ollama** - Local LLM inference on port 11434
- **Qdrant** - Vector database for embeddings on port 6333
- **Redis** - Caching and queues on port 6379
- **Postgres** - Database on port 5432

## Key Directories

- `web/src/` - React components and app code
- `web/src/App.jsx` - Main React component
- `db-migrations/migrations/` - Flyway SQL migrations
- `data/` - Persistent data for all services (gitignored)

## Common Patterns

### React Components
- Place new components in `web/src/`
- Use functional components with hooks
- Keep it simple - this user is not a coder

### Calling n8n from React
```javascript
const response = await fetch('http://localhost:5678/webhook/your-webhook-path', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ data: 'here' }),
})
const result = await response.json()
```

### Database Migrations
- Use `./db-migrations/new-migration-file.sh "description"` to create migrations
- Naming convention: `V{YYYY.MM.DD.HHMMSS}__{description}.sql`
- Run with `./db-migrations/execute-migrate.sh`

### Ollama Models
- Pull models: `docker exec -it $(docker ps -qf "ancestor=ollama/ollama") ollama pull <model>`
- Models persist in `./data/ollama/`

## Guidelines

- Keep code simple and well-commented
- Prefer straightforward solutions over clever ones
- When creating React components, include basic styling
- Always explain what code does in plain language
