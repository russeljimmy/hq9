#!/bin/bash

# Stop script for Thorium VNC Browser

echo "🛑 Stopping Thorium VNC Server..."
docker-compose down

echo "✅ Services stopped"
echo ""
echo "💾 Data is preserved in volumes (thorium-data, vnc-config)"
echo ""
echo "🗑️ To remove everything including volumes:"
echo "   docker-compose down -v"
