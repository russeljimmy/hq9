#!/bin/bash

# Quick start script for Thorium VNC Browser
set -e

echo "🚀 Thorium Browser VNC Server - Quick Start"
echo "============================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Build and start
echo "📦 Building Docker image..."
docker-compose build --pull

echo ""
echo "🚀 Starting Thorium VNC Server..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check if container is running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Container is running!"
    echo ""
    echo "🌐 Access your browser:"
    echo "   Web Interface: http://localhost:6080/vnc.html"
    echo "   VNC Password: vnc"
    echo ""
    echo "💻 VNC Clients:"
    echo "   Server: localhost:5900"
    echo "   Password: vnc"
    echo ""
    echo "📊 View logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 To stop:"
    echo "   docker-compose down"
    echo ""
else
    echo "❌ Container failed to start!"
    echo ""
    echo "📋 Check logs:"
    docker-compose logs
    exit 1
fi
