#!/bin/bash
# Exit on error
set -e

# Load environment variables if .env exists
if [ -f .env ]; then
  export $(cat .env | xargs)
fi

echo "🚀 Packaging Spring Boot application..."
chmod +x mvnw
./mvnw clean package -DskipTests

echo "🐳 Building Docker image..."
docker build -t munashechibaya/inventory-app:latest .

echo "📤 Deploying local docker-compose stack..."
docker compose down --remove-orphans || true
docker compose up -d

echo "✅ Local deployment completed successfully! App running on port 80."
