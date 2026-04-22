# Testing Guide

## Pre-Deployment Testing

### 1. File Structure Verification

```bash
# Verify all required files exist
ls -la | grep -E 'Dockerfile|docker-compose|README|BUILD_GUIDE|start.sh|manage.sh'

# Expected files:
# - Dockerfile
# - docker-compose.yml
# - README.md
# - BUILD_GUIDE.md
# - entrypoint.sh
# - vnc_startup.sh
# - openbox_rc.xml
# - .dockerignore
# - .gitignore
# - start.sh
# - stop.sh
# - manage.sh
# - Makefile
# - .env.example
```

### 2. Dockerfile Syntax Validation

```bash
# Lint Dockerfile
docker run --rm -i hadolint/hadolint < Dockerfile

# Or simple syntax check
docker build --dry-run .
```

### 3. Docker Compose Configuration

```bash
# Validate docker-compose.yml
docker-compose config

# Should output valid YAML without errors
```

### 4. Permissions Check

```bash
# Verify scripts are executable
ls -l start.sh stop.sh manage.sh entrypoint.sh vnc_startup.sh

# Should show 'x' for executable: -rwxr-xr-x
```

## Build Testing

### 1. Build Image

```bash
# Timed build with output
time docker-compose build --pull --progress=plain 2>&1 | tee build.log

# Check for errors in log
grep -i 'error' build.log
```

### 2. Image Verification

```bash
# List image
docker images thorium-vnc

# Get image details
docker image inspect thorium-vnc:latest | jq '.[] | {Architecture, Os, RootFS}'

# Check image size
docker images --format "{{.Repository}}:{{.Tag}} - {{.Size}}"
```

## Runtime Testing

### 1. Container Startup

```bash
# Start container
docker-compose up -d

# Wait 5 seconds for initialization
sleep 5

# Check if container is running
docker-compose ps

# Should show "Up X seconds"
```

### 2. Port Availability

```bash
# Test VNC port (5900)
timeout 2 bash -c '</dev/null >/dev/tcp/localhost/5900' && echo "✅ VNC port OK" || echo "❌ VNC port failed"

# Test noVNC port (6080)
curl -s -o /dev/null -w "%{http_code}" http://localhost:6080/vnc.html && echo " - noVNC OK"
```

### 3. Service Checks

```bash
# Check X server is running
docker-compose exec thorium-vnc-server ps aux | grep -i x

# Check VNC server is running
docker-compose exec thorium-vnc-server ps aux | grep -i vnc

# Check browser is running
docker-compose exec thorium-vnc-server ps aux | grep -i chromium
```

### 4. Internet Connectivity

```bash
# Test DNS
docker-compose exec thorium-vnc-server nslookup google.com

# Ping test
docker-compose exec thorium-vnc-server ping -c 3 8.8.8.8

# HTTP test
docker-compose exec thorium-vnc-server curl -I https://www.google.com

# Should get 200 OK response
```

### 5. noVNC Web Interface

```bash
# Check noVNC is responding
curl -v http://localhost:6080/vnc.html 2>&1 | grep -E 'HTTP|<!DOCTYPE'

# Download and verify index
curl -s http://localhost:6080/vnc.html | head -20
```

### 6. VNC Connection Test

```bash
# Method 1: Using vncviewer
vncviewer localhost:5900 -passwd <(echo -n "vnc" | vncpasswd -f)

# Method 2: Using Python (if installed)
python3 -c "
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
result = sock.connect_ex(('localhost', 5900))
print('✅ VNC port accessible' if result == 0 else '❌ VNC port not accessible')
sock.close()
"

# Method 3: Using bash
(sleep 0.1; echo 'RFB 003.003') | nc -q 1 localhost 5900 | head -1
```

### 7. Resource Usage

```bash
# Check container resource usage
docker stats --no-stream thorium-vnc-server

# Expected:
# - CPU: <50% (idle browser)
# - Memory: 200-400MB
# - Network: minimal (no active browsing)
```

### 8. Log Verification

```bash
# Get container logs
docker-compose logs --tail=50

# Check for errors/warnings
docker-compose logs | grep -i error

# Check for startup messages
docker-compose logs | grep -E 'Starting|port|🚀|✅'
```

## Browser Functionality Tests

### 1. Connect via Web Interface

1. Open browser to `http://localhost:6080/vnc.html`
2. Enter password: `vnc`
3. Click "Connect"
4. Verify desktop appears

### 2. Browser Navigation Test

Inside VNC:
1. Double-click Chromium icon (or wait for auto-launch)
2. Navigate to `https://www.google.com`
3. Verify page loads
4. Try searching something
5. Navigate to another site (e.g., github.com, wikipedia.org)

### 3. Media Test

1. Navigate to `https://www.youtube.com`
2. Try playing a video
3. Verify audio/video work (if audio configured)

### 4. Stability Test

```bash
# Keep container running for extended period
# Monitor resource usage over time
watch -n 5 docker stats --no-stream

# Expected: stable memory and CPU, no crashes
```

## Load & Stress Testing

### 1. Container Restart Test

```bash
# Stop and start container
docker-compose restart

# Verify it comes back up
sleep 5
docker-compose ps

# Repeat 3-5 times for stability
```

### 2. Memory Pressure

```bash
# Stress test with multiple browser tabs
# Open 50+ tabs in Chromium
# Monitor memory usage
docker stats --no-stream

# Container should not crash
```

### 3. Network Stress

```bash
# Simulate high network load
# Open heavy websites simultaneously
# Monitor network usage
docker stats --no-stream

# Should remain responsive
```

## Cleanup & Removal

```bash
# Stop services
docker-compose down

# Remove volumes
docker-compose down -v

# Remove image
docker rmi thorium-vnc:latest

# Full cleanup
docker system prune -a --volumes
```

## Test Results Report Template

```markdown
# Test Results - [DATE]

## Environment
- OS: [Ubuntu/Debian/etc]
- Docker Version: [X.XX.X]
- Docker Compose Version: [X.XX.X]
- RAM: [XXGB]
- CPU: [X cores]
- Network: [Internet Speed]

## Build
- [ ] Build successful
- [ ] Image size: ___MB
- [ ] Build time: ___min
- [ ] No errors/warnings: ___

## Runtime
- [ ] Container starts
- [ ] Stays running (5 min test)
- [ ] Logs show no errors
- [ ] Ports accessible

## Connectivity
- [ ] DNS works
- [ ] Ping works (8.8.8.8)
- [ ] HTTP/HTTPS works
- [ ] Website loads

## Web Interface
- [ ] noVNC loads
- [ ] Can authenticate
- [ ] Desktop renders
- [ ] Mouse works
- [ ] Keyboard works

## Browser Functionality
- [ ] Chromium starts
- [ ] Can navigate websites
- [ ] Multiple tabs work
- [ ] Stays stable 30 min

## Issues
- [ ] None
- [ ] Minor: _______________
- [ ] Major: _______________

## Recommendations
___________________________________
```

## Automated Testing Script

```bash
#!/bin/bash
# test.sh - Automated testing

echo "🧪 Starting tests..."

tests_passed=0
tests_failed=0

test_case() {
    local name="$1"
    local command="$2"
    
    if eval "$command" &>/dev/null; then
        echo "✅ $name"
        ((tests_passed++))
    else
        echo "❌ $name"
        ((tests_failed++))
    fi
}

# Run tests
test_case "Docker installed" "command -v docker"
test_case "Docker Compose installed" "command -v docker-compose"
test_case "Dockerfile exists" "test -f Dockerfile"
test_case "docker-compose.yml valid" "docker-compose config >/dev/null"
test_case "Container running" "docker-compose ps | grep -q 'Up'"
test_case "Port 6080 accessible" "curl -s http://localhost:6080 >/dev/null"
test_case "Port 5900 accessible" "timeout 2 bash -c '</dev/null >/dev/tcp/localhost/5900'"

echo ""
echo "Results: ✅ $tests_passed passed, ❌ $tests_failed failed"
```

Run with: `bash test.sh`
