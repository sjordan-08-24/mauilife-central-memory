---
description: Pull an Ollama model for local LLM inference
argument-hint: model-name
---

Pull the Ollama model: $ARGUMENTS

Run this command to pull the model:
```bash
docker exec -it $(docker ps -qf "ancestor=ollama/ollama") ollama pull $ARGUMENTS
```

If no model name was provided, suggest these popular options:
- `llama3.2` - Good general-purpose model
- `mistral` - Fast and capable
- `codellama` - Optimized for code
- `nomic-embed-text` - For generating embeddings (used with Qdrant)

After pulling, show how to test the model works by running a simple prompt.
