FROM docker.io/litellm/litellm:main-stable

WORKDIR /app

# Copy config
COPY config.yaml .
COPY .env .

# Expose port
EXPOSE 8000 7900

# Start LiteLLM proxy
CMD ["--port", "8000"]
