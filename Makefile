.PHONY: help start stop restart logs logs-gateway logs-db clean test-mistralapi test-mistral status health models setup

help:
	@echo "LiteLLM AI Gateway - Available Commands"
	@echo ""
	@echo "Deployment:"
	@echo "  make start              - Start gateway and database"
	@echo "  make stop               - Stop all services"
	@echo "  make restart            - Restart all services"
	@echo "  make clean              - Remove containers and volumes"
	@echo ""
	@echo "Monitoring:"
	@echo "  make status             - Show container status"
	@echo "  make logs               - View all logs (follow mode)"
	@echo "  make logs-gateway       - View gateway logs"
	@echo "  make logs-db            - View database logs"
	@echo "  make health             - Check gateway health"
	@echo ""
	@echo "Testing:"
	@echo "  make test-mistralapi    - Test Mistral Large model (default message)"
	@echo "  make test-mistral       - Test Mistral with custom message"
	@echo "                            Usage: make test-mistral MESSAGE=\"Your prompt here\""
	@echo "  make models             - List registered models"
	@echo ""
	@echo "Configuration:"
	@echo "  make setup              - Create .env from template"
	@echo ""

start:
	@echo "🚀 Starting LiteLLM Gateway..."
	podman compose up -d
	@sleep 2
	@echo "✅ Gateway started"
	@echo "   API: http://localhost:8000"
	@echo "   Dashboard: http://localhost:8000/ui"

stop:
	@echo "⏹️  Stopping services..."
	podman compose down
	@echo "✅ Services stopped"

restart: stop start
	@echo "✅ Services restarted"

clean:
	@echo "🗑️  Cleaning up containers and volumes..."
	podman compose down -v
	@echo "✅ Cleaned"

status:
	@echo "📊 Container Status:"
	podman ps | grep litellm || echo "No containers running"

logs:
	@echo "📋 Following all logs (Ctrl+C to exit)..."
	podman compose logs -f

logs-gateway:
	@echo "📋 Gateway logs:"
	podman logs litellm-gateway -f

logs-db:
	@echo "📋 Database logs:"
	podman logs litellm-db -f

health:
	@echo "🏥 Checking gateway health..."
	python3 -c "import urllib.request, json; \
[print('✅ Gateway is healthy') if json.loads(urllib.request.urlopen('http://localhost:8000/health', timeout=5).read()).get('healthy_count') is not None else None] \
if True else print('❌ Health check failed')" 2>/dev/null || echo "❌ Gateway not responding"

models:
	@echo "📋 Registered Models:"
	@python3 -c "import urllib.request, json; \
MASTER_KEY = 'your-secure-master-key-here'; \
req = urllib.request.Request('http://localhost:8000/v1/models', headers={'Authorization': f'Bearer {MASTER_KEY}'}); \
data = json.loads(urllib.request.urlopen(req, timeout=5).read()); \
print('\n'.join([f\"  • {m.get('id')}\" for m in data.get('data', [])])) if data.get('data') else print('  No models registered')" 2>/dev/null || echo "  Error fetching models"

test-mistralapi:
	@echo "🧪 Testing Mistral Large Model"
	@echo ""
	python3 scripts/test-mistral.py

test-mistral:
	@echo "🧪 Testing Mistral Large Model"
	@echo ""
	python3 scripts/test-mistral.py $(MESSAGE)

setup:
	@if [ -f .env ]; then \
		echo "⚠️  .env already exists"; \
	else \
		cp .env.example .env; \
		echo "✅ Created .env from template"; \
		echo "⚠️  Remember to edit .env with your credentials:"; \
		echo "   • MISTRAL_API_KEY"; \
		echo "   • UI_PASSWORD"; \
		echo "   • POSTGRES_PASSWORD"; \
	fi

.DEFAULT_GOAL := help
