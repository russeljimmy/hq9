.PHONY: help build up down restart logs status shell clean rebuild test-connectivity

help:
	@echo "Thorium Browser VNC Server - Make Commands"
	@echo "==========================================="
	@echo ""
	@echo "build                - Build Docker image"
	@echo "up                   - Start containers"
	@echo "down                 - Stop containers"
	@echo "restart              - Restart containers"
	@echo "logs                 - View live logs"
	@echo "status               - Check service status"
	@echo "shell                - Open shell in container"
	@echo "clean                - Remove containers & volumes"
	@echo "rebuild              - Clean rebuild image"
	@echo "test-connectivity    - Test internet connection"
	@echo "system-info          - Display system information"
	@echo "help                 - Show this help message"
	@echo ""
	@echo "Quick start: make up"
	@echo "View logs: make logs"

build:
	docker-compose build --pull

up:
	docker-compose up -d
	@echo "✅ Services started!"
	@echo "🌐 Access: http://localhost:6080/vnc.html"
	@echo "🔐 Password: vnc"

down:
	docker-compose down

restart:
	docker-compose restart
	@echo "✅ Services restarted!"

logs:
	docker-compose logs -f

status:
	docker-compose ps

shell:
	docker-compose exec thorium-vnc-server /bin/sh

clean:
	docker-compose down -v
	@echo "✅ Containers and volumes removed!"

rebuild: clean build up
	@echo "✅ Rebuild complete!"

test-connectivity:
	@echo "Testing internet connectivity..."
	@docker-compose exec thorium-vnc-server ping -c 1 8.8.8.8
	@echo "✅ Internet is working!"

system-info:
	docker-compose exec thorium-vnc-server sh -c "uname -a && echo '' && free -h && echo '' && df -h"

stats:
	docker stats --no-stream thorium-vnc-server
