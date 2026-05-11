#!/bin/bash
# FreelancerChatProtection Integration - Quick Start Script
# Run this script to start all services

set -e

echo "🚀 Starting Freelancer Platform with Chat Protection..."
echo ""
 
# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is running
echo -e "${BLUE}Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Create logs directory
mkdir -p logs

# Start services with Docker Compose
echo ""
echo -e "${YELLOW}Starting services with Docker Compose...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}✅ All services are starting!${NC}"
echo ""
echo "📍 Service URLs:"
echo "   • Backend API:        http://localhost:8000"
echo "   • Chat Protection:    http://localhost:8001"
echo "   • Face Verification:  http://localhost:8002"
echo "   • Frontend:           http://localhost:3000"
echo "   • MongoDB:            mongodb://localhost:27017"
echo ""
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
echo ""

# Wait for services to be ready
Services_Ready=0
MAX_ATTEMPTS=60
ATTEMPT=0

while [ $Services_Ready -eq 0 ] && [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:8000/api/health/ > /dev/null 2>&1 && \
       curl -s http://localhost:8001/docs > /dev/null 2>&1 && \
       curl -s http://localhost:8002/health > /dev/null 2>&1; then
        Services_Ready=1
    else
        ATTEMPT=$((ATTEMPT + 1))
        echo "   Waiting... (Attempt $ATTEMPT/$MAX_ATTEMPTS)"
        sleep 2
    fi
done

if [ $Services_Ready -eq 1 ]; then
    echo ""
    echo -e "${GREEN}✅ All services are ready!${NC}"
    echo ""
    echo "📚 Documentation & Testing:"
    echo "   • Integration Guide:  docs/CHAT_PROTECTION_INTEGRATION.md"
    echo "   • Backend API Docs:   http://localhost:8000/api/docs"
    echo "   • Protection API:     http://localhost:8001/docs"
    echo "   • Face Verification:  http://localhost:8002/docs"
    echo ""
    echo "🧪 Test the integration:"
    echo "   $ curl http://localhost:8000/api/chat/analyze/ -X POST \\"
    echo "     -H 'Authorization: Bearer YOUR_TOKEN' \\"
    echo "     -d '{\"content\": \"Hello!\"}'"
    echo ""
    echo "📊 View logs:"
    echo "   $ docker-compose logs -f backend"
    echo "   $ docker-compose logs -f protection"
    echo "   $ docker-compose logs -f face-verification"
    echo "   $ docker-compose logs -f frontend"
    echo ""
else
    echo "⚠️  Some services took too long to start. Check logs:"
    echo "   $ docker-compose logs"
    exit 1
fi
