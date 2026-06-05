# Claude Code Instructions for ai-gateway

Project-specific instructions for Claude Code when working on this repository.

## Project Overview

**ai-gateway** is a production-ready LiteLLM proxy server for Mistral AI with web-based management, PostgreSQL persistence, and OpenAI-compatible REST API.

**Status:** ✅ OPERATIONAL
- ✅ Docker Compose deployment running
- ✅ PostgreSQL database with model storage
- ✅ Mistral Large model tested & working
- ✅ Admin dashboard at http://localhost:8000/ui
- ✅ REST API with model registration

**Latest Test:** Mistral Large model successfully responding to chat completions

## Quick Start

### Prerequisites
- Podman (Fedora Silverblue)
- Docker Compose
- Mistral AI API key

### Launch
```bash
cd /var/home/fedir/Lab/ai-gateway
make setup              # Create .env from template
nano .env               # Edit with your credentials
make start              # Start services
```

Access:
- 🔌 **API**: http://localhost:8000
- 🎛️ **Admin**: http://localhost:8000/ui (see .env for credentials)

### Test
```bash
make test-mistralapi    # Test Mistral Large model
make health             # Check gateway health
make models             # List registered models
```

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

- `Makefile` - Deployment, testing, and utility commands
- `docker-compose.yml` - Container orchestration
- `scripts/test-mistral.py` - Mistral API testing script
- `.env` - Environment variables (git-ignored)
- `.env.example` - Environment template
- `requirements.txt` - Python dependencies (for local development)

## Configuration

### Environment Variables

Store all sensitive data in `.env` file (gitignored). Key variables:

```env
MISTRAL_API_KEY=your-mistral-api-key
LITELLM_MASTER_KEY=your-secure-master-key
UI_USERNAME=admin
UI_PASSWORD=your-password
POSTGRES_USER=litellm
POSTGRES_PASSWORD=your-password
POSTGRES_DB=litellm
DATABASE_URL=postgresql://litellm:your-password@postgres:5432/litellm
STORE_MODEL_IN_DB=True  # Enable dynamic model registration
```

**Important:**
- `STORE_MODEL_IN_DB=True` - Allows registering models via API
- All credentials must be strong for production
- Mistral API key from https://console.mistral.ai

⚠️ **Never commit .env** - it's in .gitignore

### Mistral Model Integration

Models are dynamically registered in the database. Register via API:

```bash
curl -X POST http://localhost:8000/model/new \
  -H "Authorization: Bearer your-secure-master-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "mistral-large",
    "litellm_params": {
      "model": "mistral/mistral-large-latest",
      "api_key": "your-mistral-api-key"
    }
  }'
```

**Status:** ✅ mistral-large model tested and working

Or configure via admin dashboard at http://localhost:8000/ui

## Common Tasks

### Using Makefile (Recommended)
```bash
make start              # Start services
make stop               # Stop services
make restart            # Restart services
make logs               # Follow all logs
make logs-gateway       # Gateway logs only
make logs-db            # Database logs only
make health             # Health check
make models             # List models
make test-mistralapi    # Test API
make clean              # Full reset
make help               # Show all commands
```

### Using Podman Directly
```bash
# View Logs
podman logs litellm-gateway -f
podman logs litellm-db -f

# Stop Gateway
podman compose down

# Restart with Fresh Database
podman compose down -v
podman compose up -d

# Access PostgreSQL CLI
podman exec -it litellm-db psql -U litellm -d litellm
```

## Makefile & Testing

### Makefile Targets
The project includes a **Makefile** with all deployment and testing commands:

**Deployment:**
- `make start` - Start gateway and database
- `make stop` - Stop all services
- `make restart` - Restart services
- `make clean` - Remove containers and volumes

**Monitoring:**
- `make status` - Show container status
- `make logs` - Follow all logs
- `make logs-gateway` / `make logs-db` - Component-specific logs
- `make health` - Health check
- `make models` - List registered models

**Testing:**
- `make test-mistralapi` - Run comprehensive Mistral API test

**Configuration:**
- `make setup` - Create .env from template
- `make help` - Display all commands

### Testing Script (scripts/test-mistral.py)
Comprehensive test for Mistral Large model:
- Tests `/chat/completions` endpoint
- Validates Bearer token authentication
- Reports token usage and spend
- Handles errors gracefully:
  - HTTP errors (401, 500, etc.)
  - Connection failures
  - Timeout handling

Example output:
```
✅ Mistral Large Model Test Successful

Response:
  Hello! I'm an AI here to help...

Tokens used: 52
```

## API Usage

### List Available Models
```bash
curl http://localhost:8000/models
```

### Chat Completion (Mistral)
```bash
curl -X POST http://localhost:8000/chat/completions \
  -H "Authorization: Bearer your-secure-master-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral-large",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 100,
    "temperature": 0.7
  }'
```

**Response:**
```json
{
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "Your response here..."
    }
  }],
  "usage": {
    "total_tokens": 25
  }
}
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
