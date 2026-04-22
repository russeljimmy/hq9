# 🌐 Thorium Browser VNC Server

A lightweight, stable, and fully internet-connected Linux VNC desktop environment running Thorium/Chromium browser inside a Docker container. Perfect for remote browsing, automation, and headless browser operations.

## ✨ Features

- **Lightweight Setup**: Based on Alpine Linux (~100MB base image)
- **No Crashes**: Optimized Chromium settings for container stability
- **Internet Connectivity**: Full network access with DNS resolution
- **VNC Remote Desktop**: Connect via VNC client (port 5900)
- **Web Browser Access**: noVNC web interface (port 6080) - no VNC client needed
- **Audio Support**: PulseAudio for multimedia playback
- **Easy Deployment**: Docker & Docker Compose for simple setup
- **Health Checks**: Automated monitoring and restart on failure
- **Persistent Storage**: Browser profile and VNC config persistence

## 🚀 Quick Start

### Prerequisites

- **Docker** (version 20.10+)
- **Docker Compose** (version 1.29+)
- Internet connection

### Installation & Running

#### Option 1: Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/russeljimmy/hq9.git
cd hq9

# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f
```

#### Option 2: Docker CLI

```bash
# Build the image
docker build -t thorium-vnc .

# Run the container
docker run -d \
  --name thorium-vnc-server \
  -p 5900:5900 \
  -p 6080:6080 \
  -p 9222:9222 \
  -v thorium-data:/root/.config/chromium \
  -v vnc-config:/root/.vnc \
  -e VNC_PASSWORD=vnc \
  --restart unless-stopped \
  thorium-vnc
```

## 🔗 Accessing the Browser

### Via Web Browser (Easiest)
- **URL**: `http://localhost:6080/vnc.html`
- **VNC Password**: `vnc`
- Works on any device with a web browser

### Via VNC Client
- **Server**: `localhost:5900`
- **Password**: `vnc`
- **Recommended Clients**:
  - TigerVNC Viewer
  - RealVNC
  - VNC Viewer
  - Remmina (Linux)

### Remote Access (Over Network)
```bash
# Forward ports to your local machine
ssh -L 6080:localhost:6080 user@remote-server

# Then access: http://localhost:6080/vnc.html
```

## 🛠️ Configuration

### Change VNC Password

Edit the Dockerfile (line: `echo "vnc" | vncpasswd -f`) or build-time variable:

```bash
docker run -e VNC_PASSWORD=yourpassword thorium-vnc
```

### Adjust Display Resolution

Edit `docker-compose.yml` or Dockerfile to change geometry:

```bash
# Change from 1280x960 to 1920x1080
# In entrypoint.sh, change:
# Xvfb :1 -screen 0 1280x960x24
# to:
Xvfb :1 -screen 0 1920x1080x24
```

### Enable GPU Acceleration (if host has GPU)

Uncomment in docker-compose.yml:
```yaml
devices:
  - /dev/dri:/dev/dri
```

And modify CHROMIUM_FLAGS to remove `--disable-gpu`

### Custom Browser Startup

Modify the browser launch command in `entrypoint.sh`:

```bash
CHROMIUM_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-port=9222 --volume-state='/custom/path'"
chromium $CHROMIUM_FLAGS &
```

## 📊 System Resources

- **Minimum**: 1 CPU, 512MB RAM
- **Recommended**: 2 CPUs, 1-2GB RAM
- **Disk**: ~500MB (image) + cache

## 🐛 Troubleshooting

### Connection Refused

```bash
# Check if container is running
docker-compose ps

# View logs
docker-compose logs

# Restart container
docker-compose restart
```

### Browser Not Starting

```bash
# Check logs for errors
docker-compose logs | grep -i error

# Rebuild image
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### High CPU Usage

- Disable auto-update in Chromium settings
- Use `--disable-background-networking` flag
- Modify CHROMIUM_FLAGS in entrypoint.sh

### No Internet Connection

```bash
# Check DNS
docker exec thorium-vnc-server nslookup google.com

# Verify network
docker exec thorium-vnc-server ping 8.8.8.8

# Restart networking
docker-compose restart
```

### Audio Issues

Uncomment in docker-compose.yml:
```yaml
devices:
  - /dev/snd:/dev/snd
```

## 🔒 Security Considerations

⚠️ **Important**: This setup is designed for local/trusted networks.

For production use:
- Change the VNC password from `vnc` to a strong password
- Use reverse proxy with authentication (Nginx + OAuth2)
- Restrict network access with firewall rules
- Run behind a VPN
- Use TLS/SSL certificates for web access

Example secure setup:
```bash
# Generate strong password
docker run --rm thorium-vnc vncpasswd -f <<< "YOUR_STRONG_PASSWORD" > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Run with custom password
docker run -d -v ~/.vnc/passwd:/root/.vnc/passwd thorium-vnc
```

## 📡 Advanced Usage

### Remote Debugging Protocol (RDP)

Chromium is started with `--remote-debugging-port=9222`. Use it for automation:

```bash
# Example: Python Selenium automation
from selenium import webdriver

options = webdriver.ChromeOptions()
options.debugger_address = "localhost:9222"
driver = webdriver.Chrome(options=options)
```

### API Endpoints

Access container services:

| Service | Port | Protocol | Access |
|---------|------|----------|--------|
| VNC | 5900 | VNC | VNC Clients |
| noVNC | 6080 | HTTP | Web Browser |
| Chromium Debug | 9222 | HTTP | WebSocket/Chrome DevTools |

### Container Management

```bash
# View running processes inside container
docker-compose exec thorium-vnc-server ps aux

# Get shell access
docker-compose exec thorium-vnc-server /bin/sh

# View resource usage
docker stats thorium-vnc-server

# Check health
docker-compose ps

# Stop container
docker-compose stop

# Remove container and volumes
docker-compose down -v
```

## 🔄 Updating

```bash
# Pull latest changes
git pull

# Rebuild image
docker-compose down
docker-compose build --no-cache

# Start fresh
docker-compose up -d
```

## 📦 What's Included

- **Alpine Linux 3.19**: Minimal footprint (~5MB core)
- **TigerVNC Server**: High-performance VNC server
- **noVNC**: Web-based VNC client
- **Xvfb**: Virtual framebuffer for headless operation
- **OpenBox**: Lightweight window manager
- **PulseAudio**: Audio support
- **Chromium/Thorium**: Web browser engine
- **Standard Fonts**: Liberation fonts for web compatibility
- **Network Tools**: curl, wget for connectivity verification

## 🤝 Contributing

Improvements welcome! Feel free to:
- Report issues
- Submit pull requests
- Suggest optimizations
- Add documentation

## 📝 License

MIT License - Feel free to use for personal and commercial projects.

## ⚡ Performance Tips

1. **Disable unnecessary extensions** in browser
2. **Use lightweight websites** - heavy JS sites may lag over remote connections
3. **Adjust network bandwidth** - VNC compression settings
4. **Monitor container memory** - adjust JVM heap if needed
5. **Use persistent volumes** - speeds up repeat launches

## 📞 Support & Debugging

For issues, check:

```bash
# Full system diagnostics
docker-compose exec thorium-vnc-server sh -c "
  echo '=== System Info ===' && \
  uname -a && \
  echo '=== Disk Usage ===' && \
  df -h && \
  echo '=== Memory ===' && \
  free -h && \
  echo '=== Network ===' && \
  ifconfig && \
  echo '=== DNS ===' && \
  cat /etc/resolv.conf
"
```

## 🎯 Use Cases

- ✅ Remote browser automation
- ✅ Headless web scraping
- ✅ Testing responsive designs
- ✅ Running browser-based applications
- ✅ Virtual desktop for remote workers
- ✅ Continuous integration/testing environments
- ✅ Screenshot capture service
- ✅ Secure browsing environment

---

**Version**: 1.0.0  
**Last Updated**: 2026-04-22  
**Status**: ✅ Production Ready