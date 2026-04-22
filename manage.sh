#!/bin/bash

# Management script for Thorium VNC Browser

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_menu() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Thorium VNC Browser - Management${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "1. Start services"
    echo "2. Stop services"
    echo "3. Restart services"
    echo "4. View logs (live)"
    echo "5. Check status"
    echo "6. Shell access"
    echo "7. View system info"
    echo "8. Test internet connectivity"
    echo "9. Rebuild image"
    echo "10. View ports & connections"
    echo "11. Clean up (remove containers & volumes)"
    echo "0. Exit"
    echo ""
}

start_services() {
    echo -e "${YELLOW}Starting services...${NC}"
    docker-compose up -d
    sleep 2
    if docker-compose ps | grep -q "Up"; then
        echo -e "${GREEN}✅ Services started successfully!${NC}"
        echo "🌐 Access: http://localhost:6080/vnc.html"
    else
        echo -e "${RED}❌ Failed to start services${NC}"
    fi
}

stop_services() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Services stopped${NC}"
}

restart_services() {
    echo -e "${YELLOW}Restarting services...${NC}"
    docker-compose restart
    sleep 2
    echo -e "${GREEN}✅ Services restarted${NC}"
}

view_logs() {
    echo -e "${YELLOW}Showing live logs (press Ctrl+C to exit)...${NC}"
    docker-compose logs -f
}

check_status() {
    echo -e "${YELLOW}Service Status:${NC}"
    docker-compose ps
    echo ""
    
    echo -e "${YELLOW}Resource Usage:${NC}"
    docker stats --no-stream thorium-vnc-server 2>/dev/null || echo "Container not running"
}

shell_access() {
    echo -e "${YELLOW}Opening shell in container...${NC}"
    docker-compose exec thorium-vnc-server /bin/sh
}

view_system_info() {
    echo -e "${YELLOW}System Information:${NC}"
    docker-compose exec thorium-vnc-server sh -c "
        echo '=== OS Info ===' && \
        cat /etc/os-release && \
        echo '' && \
        echo '=== CPU ===' && \
        nproc && \
        echo '' && \
        echo '=== Memory ===' && \
        free -h && \
        echo '' && \
        echo '=== Disk ===' && \
        df -h && \
        echo '' && \
        echo '=== Running Processes ===' && \
        ps aux | head -20
    "
}

test_connectivity() {
    echo -e "${YELLOW}Testing internet connectivity...${NC}"
    echo ""
    
    echo "Testing DNS resolution..."
    if docker-compose exec thorium-vnc-server nslookup google.com &>/dev/null; then
        echo -e "${GREEN}✅ DNS working${NC}"
    else
        echo -e "${RED}❌ DNS issue${NC}"
    fi
    
    echo ""
    echo "Testing ping (8.8.8.8)..."
    if docker-compose exec thorium-vnc-server ping -c 1 8.8.8.8 &>/dev/null; then
        echo -e "${GREEN}✅ Internet accessible${NC}"
    else
        echo -e "${RED}❌ No internet access${NC}"
    fi
    
    echo ""
    echo "Testing HTTP connection..."
    if docker-compose exec thorium-vnc-server curl -s -m 5 https://www.google.com >/dev/null 2>&1; then
        echo -e "${GREEN}✅ HTTPS working${NC}"
    else
        echo -e "${YELLOW}⚠️  HTTPS might be limited${NC}"
    fi
}

rebuild_image() {
    echo -e "${YELLOW}Rebuilding Docker image (this may take a few minutes)...${NC}"
    docker-compose down
    docker-compose build --no-cache --pull
    echo -e "${GREEN}✅ Image rebuilt${NC}"
}

view_ports() {
    echo -e "${YELLOW}Open Ports & Connections:${NC}"
    docker-compose ps
    echo ""
    echo "Port Mappings:"
    echo "  VNC:        localhost:5900"
    echo "  noVNC:      localhost:6080"
    echo "  Chromium:   localhost:9222"
    echo ""
    
    echo -e "${YELLOW}Testing port accessibility:${NC}"
    
    # Test VNC port
    if timeout 2 bash -c '</dev/null >/dev/tcp/localhost/5900' 2>/dev/null; then
        echo -e "${GREEN}✅ Port 5900 (VNC) is accessible${NC}"
    else
        echo -e "${RED}❌ Port 5900 (VNC) is not accessible${NC}"
    fi
    
    # Test noVNC port
    if curl -s http://localhost:6080/vnc.html >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Port 6080 (noVNC) is accessible${NC}"
    else
        echo -e "${RED}❌ Port 6080 (noVNC) is not accessible${NC}"
    fi
}

cleanup() {
    echo -e "${YELLOW}Cleaning up (removing containers and volumes)...${NC}"
    docker-compose down -v
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Main loop
while true; do
    show_menu
    read -p "Select option [0-11]: " choice
    
    case $choice in
        1) start_services ;;
        2) stop_services ;;
        3) restart_services ;;
        4) view_logs ;;
        5) check_status ;;
        6) shell_access ;;
        7) view_system_info ;;
        8) test_connectivity ;;
        9) rebuild_image ;;
        10) view_ports ;;
        11) read -p "Are you sure? (yes/no): " confirm && [[ "$confirm" == "yes" ]] && cleanup ;;
        0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
done
