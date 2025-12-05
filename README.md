# Local Dev Stack

A Docker Compose setup for rapid local development with n8n workflows, LLM inference, vector storage, and Postgres.

## Services

| Service | Description | Port |
|---------|-------------|------|
| **Web** | React frontend | [localhost:3000](http://localhost:3000) |
| **n8n** | Workflow automation | [localhost:5678](http://localhost:5678) |
| **Ollama** | Local LLM inference | 11434 |
| **Qdrant** | Vector database | 6333 (HTTP), 6334 (gRPC) |
| **Redis** | Cache/queue | 6379 |
| **Postgres** | Database | 5432 |

## Quick Start

```bash
./start.sh           # Start all services
./start.sh -d        # Start all services (detached)
./start.sh web       # Start just web
./start.sh n8n       # Start n8n stack
./start.sh postgres  # Start just postgres
```

The start script checks Docker is running, creates `.env` if missing, and sets up data directories automatically.

## Web UI (React)

The `./web` folder contains a React app with hot reloading. Edit files and see changes instantly.

**Key files:**
- `web/src/App.jsx` - Main component (start here)
- `web/src/App.css` - Styles for App
- `web/index.html` - Page title and meta tags

The boilerplate includes an example of calling an n8n webhook. Create a webhook in n8n, update the URL in `App.jsx`, and click the button to test.

## Ollama (Local LLMs)

Ollama starts empty. Pull a model before using it:

```bash
# Pull a model (run while Ollama container is running)
docker exec -it $(docker ps -qf "ancestor=ollama/ollama") ollama pull llama3.2

# Other popular models
docker exec -it $(docker ps -qf "ancestor=ollama/ollama") ollama pull mistral
docker exec -it $(docker ps -qf "ancestor=ollama/ollama") ollama pull nomic-embed-text  # for embeddings

# List downloaded models
docker exec -it $(docker ps -qf "ancestor=ollama/ollama") ollama list
```

Models are stored in `./data/ollama/` and persist across restarts.

Browse available models at [ollama.com/library](https://ollama.com/library).

## Configuration

Copy `.env.example` to `.env` to customize:

```bash
POSTGRES_USER=postgres_admin
POSTGRES_PASSWORD=S3cret
POSTGRES_DB=postgres
N8N_ENCRYPTION_KEY=change_me
```

## Database Migrations

Uses [Flyway](https://flywaydb.org/) for versioned migrations.

```bash
cd db-migrations

# Run baseline - MUST BE RAN ONE TIME ONLY, PRIOR TO RUNNING ANY MIGRATIONS
./execute-baseline.sh

# Create a new migration
./new-migration-file.sh "add users table"

# Run migrations
./execute-migrate.sh

# Validate migrations
./execute-validate.sh

# View migration info
./execute-info.sh
```

Migration files follow the naming convention: `V{YYYY.MM.DD.HHMMSS}__{description}.sql`

## Data Persistence

All service data is stored in `./data/` (gitignored):
- `./data/postgres/` - Database files
- `./data/n8n/` - Workflows and credentials
- `./data/ollama/` - Downloaded models
- `./data/qdrant/` - Vector storage
- `./data/redis/` - Redis persistence
