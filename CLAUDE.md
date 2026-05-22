# Claude Code Instructions for ai-gateway

This document contains project-specific instructions for Claude Code when working on this repository.

## Project Overview

**ai-gateway** is a local LiteLLM proxy server for testing and managing Mistral AI API access with a web admin dashboard.

**Status:** ✅ Production Ready
- Running on Docker Compose
- PostgreSQL database for authentication
- Admin dashboard accessible at http://localhost:8000/ui

## Quick Start

### Prerequisites
- Podman (Fedora Silverblue)
- Docker Compose
- Mistral AI API key

### Launch
```bash
cd /var/home/fedir/Lab/ai-gateway
cp .env.example .env
# Edit .env with your credentials
podman compose up -d
```

Access:
- 🔌 **API**: http://localhost:8000
- 🎛️ **Admin**: http://localhost:8000/ui (see .env for credentials)

## Architecture

```
┌─────────────────────────────────────────┐
│   LiteLLM Gateway Container             │
│  ┌─────────────────────────────────────┐│
│  │ Uvicorn (Port 8000)                 ││
│  │ ├── /ui (Admin Dashboard)           ││
│  │ ├── /chat/completions (API)         ││
│  │ └── /health (Health Check)          ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────┐
│   PostgreSQL Container (Port 5432)      │
│   - Authentication                      │
│   - User Management                     │
│   - API Logs                            │
└─────────────────────────────────────────┘
            ↓
        Mistral AI API
        (External Service)
```

## Key Files

- `docker-compose.yml` - Container orchestration
- `config.yaml` - Model configuration (optional)
- `.env` - Environment variables
- `requirements.txt` - Python dependencies (for local development)

## Configuration

### Environment Variables

Store all sensitive data in `.env` file (gitignored). See `.env.example` for template:

- `MISTRAL_API_KEY` - Mistral AI API credentials
- `LITELLM_MASTER_KEY` - Master authentication key
- `UI_USERNAME` - Admin dashboard username
- `UI_PASSWORD` - Admin dashboard password (change from default)
- `POSTGRES_USER` - Database username
- `POSTGRES_PASSWORD` - Database password (change from default)
- `DATABASE_URL` - PostgreSQL connection string

⚠️ **Never commit .env** - it's in .gitignore

### Modify Models

Edit the LiteLLM config via admin dashboard or mount a config.yaml:

```yaml
model_list:
  - model_name: mistral-large
    litellm_params:
      model: mistral/mistral-large-latest
      api_key: ${MISTRAL_API_KEY}
```

## Common Tasks

### View Logs
```bash
podman logs litellm-gateway -f
podman logs litellm-db -f
```

### Stop Gateway
```bash
podman compose down
```

### Restart with Fresh Database
```bash
podman compose down -v
podman compose up -d
```

### Access PostgreSQL CLI
```bash
podman exec -it litellm-db psql -U litellm -d litellm
```

## API Usage

### List Available Models
```bash
curl http://localhost:8000/models
```

### Chat Completion
```bash
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral-large",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Health Check
```bash
curl http://localhost:8000/health
```

## Troubleshooting

**Port Already in Use**
```bash
# Kill processes on ports 8000, 7900, 5432
lsof -i :8000 | grep -v COMMAND | awk '{print $2}' | xargs kill -9
```

**Database Connection Failed**
```bash
# Check PostgreSQL is running
podman ps | grep litellm-db

# Verify database connection
podman exec litellm-db pg_isready -U litellm -d litellm
```

**Admin Login Not Working**
- Ensure UI_USERNAME and UI_PASSWORD are set
- Database must be running
- Check gateway logs: `podman logs litellm-gateway`

## Development Notes

- The gateway uses Uvicorn ASGI server
- Authentication is database-backed (PostgreSQL)
- Admin UI is a Next.js application
- All requests are proxied to Mistral AI API
- Logs are stored in PostgreSQL for audit trail

## Security Considerations

- Change default UI credentials in production
- Use a strong LITELLM_MASTER_KEY
- Rotate API keys regularly
- Use environment variables for secrets
- Don't commit credentials to version control

## References

- [LiteLLM Documentation](https://docs.litellm.ai)
- [Mistral AI API](https://docs.mistral.ai)
- [Docker Compose](https://docs.docker.com/compose/)
