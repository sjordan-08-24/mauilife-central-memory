---
description: Brainstorm and build an n8n workflow
argument-hint: what the workflow should do
---

Help me build an n8n workflow for: $ARGUMENTS

Guide me through:
1. What this workflow will accomplish
2. The trigger to use (webhook, schedule, etc.)
3. Step-by-step nodes needed
4. How to connect it to the React frontend (if applicable)

Keep explanations simple and non-technical. If I need to use the Ollama or Qdrant nodes, explain how to configure them.

If no idea was provided, suggest some useful workflows:
- Form submission handler (receive data from React, save to Postgres)
- AI chatbot endpoint (receive message, send to Ollama, return response)
- Scheduled data processor (run daily, query Postgres, generate report)
- RAG pipeline (store documents in Qdrant, query with AI)
