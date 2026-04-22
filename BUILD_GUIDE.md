# Build & Deployment Guide

## Quick Build & Test Locally

### Prerequisites

```bash
# Install Docker & Docker Compose
sudo apt update
sudo apt install -y docker.io docker-compose

# Add user to docker group (to run without sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

### Build the Image

```bash
# Navigate to repository
cd hq9

# Build image (first time ~10-15 minutes depending on internet)
docker-compose build

# Or using docker directly
docker build -t thorium-vnc:latest .
```

### Run the Container

```bash
# Method 1: Using Docker Compose (Recommended)
docker-compose up -d

# Method 2: Manual startup script
bash start.sh

# Method 3: Using Make
make up
```

### Access the Browser

1. **Web Interface (Easiest)**
   - Open your browser
   - Navigate to: `http://localhost:6080/vnc.html`
   - Password: `vnc`

2. **VNC Client**
   - Install TigerVNC Viewer or RealVNC
   - Connect to: `localhost:5900`
   - Password: `vnc`

3. **Remote Access**
   ```bash
   ssh -L 6080:localhost:6080 user@server
   # Then access: http://localhost:6080/vnc.html
   ```

## Troubleshooting Build Issues

### Issue: Package not found / Installation fails

**Solution**: Rebuild without cache

```bash
docker-compose build --no-cache --pull
```

### Issue: Port already in use

```bash
# Find and kill process using port 5900 or 6080
lsof -i :5900
lsof -i :6080

# Or change ports in docker-compose.yml
```

### Issue: Build takes too long

- This is normal on first build (~10-15 minutes)
- Network speed affects download time
- Chromium is ~200MB to download

### Issue: Container exits immediately

```bash
# Check logs
docker-compose logs

# Or
docker logs thorium-vnc-server

# Rebuild with verbose output
docker-compose build --progress=plain
```

## Verification Checklist

After deployment:

- [ ] Container is running: `docker-compose ps`
- [ ] Port 6080 is accessible: `curl http://localhost:6080/vnc.html`
- [ ] Port 5900 is accessible: `timeout 2 bash -c '</dev/null >/dev/tcp/localhost/5900'`
- [ ] Browser loads in noVNC web interface
- [ ] Can navigate to a website (e.g., google.com)
- [ ] Internet connectivity works

## Performance Tuning

### For Low-Memory Systems (512MB)

In `docker-compose.yml`, add:
```yaml
memory: '512m'
memswap: '512m'
```

### For High-Latency Networks

In entrypoint.sh, modify VNC settings:
```bash
vncserver :1 -geometry 1280x960 -depth 16 -rfbport 5900  # Lower color depth
```

### For Better Performance

```bash
# Increase available resources
docker-compose down -v
docker run -d --name thorium-vnc \
  -p 5900:5900 -p 6080:6080 \
  -m 2g \
  --cpus=2 \
  thorium-vnc:latest
```

## Deployment on Server

### Via SSH

```bash
# 1. Clone repo
git clone https://github.com/russeljimmy/hq9.git
cd hq9

# 2. Build (can take 10-20 minutes on slower connections)
docker-compose build --pull

# 3. Start in background
docker-compose up -d

# 4. Verify
docker-compose ps
```

### Via Docker Pull (if image is on registry)

```bash
# Pull from Docker Hub (if available)
docker pull russeljimmy/thorium-vnc:latest

# Or pull from GitHub Container Registry
docker pull ghcr.io/russeljimmy/hq9:latest

# Run with docker-compose override
docker-compose up -d
```

## Example Systemd Service (for running on system startup)

Create `/etc/systemd/system/thorium-vnc.service`:

```ini
[Unit]
Description=Thorium Browser VNC Server
After=docker.service
Requires=docker.service

[Service]
Type=simple
WorkingDirectory=/path/to/hq9
ExecStart=/usr/bin/docker-compose up
ExecStop=/usr/bin/docker-compose down
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Then enable:

```bash
sudo systemctl enable thorium-vnc.service
sudo systemctl start thorium-vnc.service
sudo systemctl status thorium-vnc.service
```

## Monitoring & Logs

```bash
# View logs in real-time
docker-compose logs -f

# View specific number of lines
docker-compose logs --tail=100

# Check resource usage
docker stats

# Get into container shell
docker-compose exec thorium-vnc-server /bin/bash
```

## Cleanup

```bash
# Stop containers
docker-compose down

# Remove containers and volumes
docker-compose down -v

# Remove image
docker rmi thorium-vnc:latest

# Remove all unused Docker resources
docker system prune -a
```

## Production Deployment Checklist

- [ ] Change VNC password from default
- [ ] Enable firewall rules
- [ ] Use reverse proxy (Nginx) with SSL
- [ ] Set resource limits (memory, CPU)
- [ ] Configure logging
- [ ] Set up monitoring/alerting
- [ ] Backup browser profile volumes
- [ ] Test failover/restart procedures
- [ ] Document access URLs and credentials
- [ ] Regular updates and security patches
