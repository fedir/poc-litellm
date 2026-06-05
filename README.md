# LiteLLM AI Gateway - Mistral AI Proxy

A production-ready local LiteLLM proxy server for Mistral AI with a web-based admin dashboard, PostgreSQL backend, and OpenAI-compatible REST API.

## Status: ✅ OPERATIONAL

Mistral Large model fully integrated and tested. Gateway running with persistent model storage.

## Features

✅ **Mistral AI Integration** - mistral-large-latest model configured & tested  
✅ **LiteLLM Proxy** - Unified API interface for multiple LLMs  
✅ **Admin Dashboard** - Web UI for model management and monitoring  
✅ **PostgreSQL** - Database for authentication, models, and audit logs  
✅ **Docker Compose** - Simple containerized deployment  
✅ **REST API** - OpenAI-compatible chat completions endpoint  
✅ **Model Registration** - Dynamic model management via API  

## Quick Start

### Prerequisites

- **Podman** (or Docker)
- **Docker Compose** 
- **Mistral AI API Key** - Get one at https://console.mistral.ai

### Installation

```bash
# Navigate to project directory
cd ai-gateway

# Create .env file from template
make setup

# Edit .env and add your credentials
nano .env

# Start the gateway
make start
```

**Configure in .env:**
- `MISTRAL_API_KEY` - Your Mistral API key from https://console.mistral.ai
- `UI_PASSWORD` - Strong password for admin dashboard
- `POSTGRES_PASSWORD` - PostgreSQL password

### Access

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| **Admin Dashboard** | http://localhost:8000/ui | admin / (see .env) |
| **API Endpoint** | http://localhost:8000 | - |
| **API Docs** | http://localhost:8000/redoc | - |
| **Database** | localhost:5432 | (see .env) |

## Mistral AI Integration

The gateway comes pre-configured with **Mistral Large** model. After setting your API key in `.env` and starting the services:

### Register a Model
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

### Test the Model

**Using Makefile (Recommended):**
```bash
# Test with default message
make test-mistralapi

# Test with custom prompt
make test-mistral What is 2+2?
make test-mistral hello world
```

Both run `scripts/test-mistral.py` which tests the Mistral Large model integration with error handling.

**Manual API Test:**
```python
import urllib.request
import json

payload = json.dumps({
    "model": "mistral-large",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 100
}).encode()

req = urllib.request.Request(
    'http://localhost:8000/chat/completions',
    data=payload,
    headers={
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your-secure-master-key-here'
    }
)

with urllib.request.urlopen(req) as r:
    response = json.loads(r.read())
    print(response['choices'][0]['message']['content'])
```

## Usage

### Web Admin Dashboard

1. Navigate to http://localhost:8000/ui
2. Login with credentials from your .env file (UI_USERNAME / UI_PASSWORD)
3. Manage models, view API logs, monitor usage

### API - Chat Completions

```bash
curl -X POST http://localhost:8000/chat/completions \
  -H "Authorization: Bearer your-secure-master-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral-large",
    "messages": [
      {
        "role": "user",
        "content": "Hello, how are you?"
      }
    ],
    "max_tokens": 100,
    "temperature": 0.7
  }'
```

**Response:**
```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "I'm doing well, thank you for asking! How can I help you today?"
      }
    }
  ],
  "usage": {
    "total_tokens": 25
  }
}
```

### Check Health

```bash
curl http://localhost:8000/health
```

## Configuration

### docker-compose.yml

The main configuration file with:
- **litellm** service (port 8000)
- **postgres** service (port 5432)
- Environment variables for credentials
- Volume mounts for persistence

### Environment Variables

See `.env.example` for all available options. Create a `.env` file with:

```env
MISTRAL_API_KEY=your-mistral-api-key
LITELLM_MASTER_KEY=secure-master-key
UI_USERNAME=admin
UI_PASSWORD=strong-password
POSTGRES_USER=litellm
POSTGRES_PASSWORD=strong-password
POSTGRES_DB=litellm
DATABASE_URL=postgresql://litellm:strong-password@postgres:5432/litellm
STORE_MODEL_IN_DB=True
```

**Key Variables:**
- `MISTRAL_API_KEY` - Get from https://console.mistral.ai
- `LITELLM_MASTER_KEY` - For API authentication
- `STORE_MODEL_IN_DB=True` - Enables dynamic model registration

⚠️ **Never commit .env to version control** - it's in .gitignore

### Model Configuration

Models are stored in the database (enabled by `STORE_MODEL_IN_DB=True`). Configure via:
1. **Admin Dashboard** - Web UI for easy management
2. **API Endpoints** - Programmatic configuration (`/model/new`)
3. **Database** - Models persist across restarts

## Docker Compose Services

### litellm-gateway
- **Image**: ghcr.io/berriai/litellm:main-stable
- **Port**: 8000 (API), 7900 (Admin)
- **Dependencies**: PostgreSQL
- **Function**: LLM proxy server with admin UI

### litellm-db
- **Image**: postgres:15-alpine
- **Port**: 5432
- **Credentials**: (see .env for POSTGRES_USER / POSTGRES_PASSWORD)
- **Database**: litellm
- **Function**: Authentication and audit logs

## Common Commands

All commands are available via **Makefile** for simplicity:

```bash
# Start services
make start

# Stop services
make stop

# Restart services
make restart

# View logs (all services)
make logs

# View gateway logs only
make logs-gateway

# View database logs only
make logs-db

# Check container status
make status

# Health check
make health

# List registered models
make models

# Test Mistral API
make test-mistralapi

# Clean up containers and volumes
make clean
```

**Or use raw Podman commands:**
```bash
# Start
podman compose up -d

# Stop
podman compose down

# View logs
podman logs litellm-gateway -f
podman logs litellm-db -f

# Access Database CLI
podman exec -it litellm-db psql -U litellm -d litellm
```

## Makefile Reference

The project includes a **Makefile** for simplified deployment and testing:

### Deployment Commands
- `make start` - Start gateway and database containers
- `make stop` - Stop all services
- `make restart` - Restart all services
- `make clean` - Remove containers and volumes (full reset)

### Monitoring Commands
- `make status` - Show container status
- `make logs` - Follow all service logs
- `make logs-gateway` - Follow gateway logs only
- `make logs-db` - Follow database logs only
- `make health` - Check gateway health status

### Testing Commands
- `make test-mistralapi` - Test Mistral Large model with default message
- `make test-mistral <message>` - Test with custom prompt (words separated by spaces)
- `make models` - List registered models in the gateway

### Configuration Commands
- `make setup` - Create `.env` file from `.env.example` template
- `make help` - Display all available commands

### Testing Script
**scripts/test-mistral.py** provides comprehensive Mistral API testing:
- Tests `/chat/completions` endpoint
- Validates Bearer token authentication
- Reports token usage and cost
- Handles errors gracefully (HTTP errors, connection failures, timeouts)

## API Endpoints

### Models
```
GET  /models                    # List available models
POST /models                    # Create new model
```

### Chat
```
POST /chat/completions          # Chat completion (OpenAI compatible)
```

### Health
```
GET  /health                    # Health status
```

### Admin
```
GET  /ui                        # Web dashboard
GET  /ui/login                  # Login page
GET  /redoc                     # API documentation
GET  /openapi.json              # OpenAPI schema
```

## Troubleshooting

### Port Already in Use
```bash
# Find and kill process using port
lsof -i :8000 | grep -v COMMAND | awk '{print $2}' | xargs kill -9
```

### Database Connection Failed
```bash
# Check if PostgreSQL is running
podman ps | grep litellm-db

# Test database connection
podman exec litellm-db pg_isready -U litellm -d litellm
```

### Admin Login Error
1. Verify UI_USERNAME and UI_PASSWORD in docker-compose.yml
2. Ensure database is running: `podman compose logs litellm-db`
3. Check gateway logs: `podman compose logs litellm-gateway`
4. Restart gateway: `podman compose restart litellm-gateway`

### Models Not Available
1. Register models via Admin Dashboard or API endpoint (`/model/new`)
2. Verify Mistral API key is correct in `.env`
3. Check database is running: `podman ps | grep litellm-db`
4. View logs for errors: `podman logs litellm-gateway`
5. Ensure model names match Mistral's model IDs (e.g., `mistral/mistral-large-latest`)

## Architecture

```
Client
  │
  ├─→ HTTP :8000 (API)          ← LiteLLM Gateway
  │                              ├─→ Mistral AI API
  │                              └─→ PostgreSQL :5432
  │
  └─→ Browser :8000/ui (Admin)   ← Web Dashboard (Next.js)
```

## Security

⚠️ **For Development Only** - Not suitable for production without:

- [ ] Change default credentials
- [ ] Use environment variables for secrets
- [ ] Enable SSL/TLS (nginx reverse proxy)
- [ ] Restrict API key access
- [ ] Implement rate limiting
- [ ] Use strong master key
- [ ] Regular security updates
- [ ] Audit logs review

## Development

### Local Development
```bash
# Create Python virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run locally
python gateway.py
```

### Project Structure
```
ai-gateway/
├── docker-compose.yml      # Container orchestration
├── .env                    # Environment variables (git-ignored)
├── Makefile               # Deployment and testing commands
├── scripts/               # Helper scripts (test-mistral.py)
├── requirements.txt        # Python dependencies
├── CLAUDE.md              # Claude Code instructions
├── README.md              # This file
└── Dockerfile             # Container image
```

## References

- [LiteLLM Documentation](https://docs.litellm.ai)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)
- [Mistral AI Docs](https://docs.mistral.ai)
- [Mistral API Reference](https://docs.mistral.ai/api/)
- [Docker Compose](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## License

MIT

## Support

For issues and questions:
- Check the CLAUDE.md for detailed instructions
- Review LiteLLM documentation
- Check gateway logs: `podman logs litellm-gateway`

---

**Last Updated**: May 22, 2026  
**Status**: ✅ Working  
**Gateway Version**: LiteLLM main-stable
