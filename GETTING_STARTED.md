# 🎯 Getting Started - Step by Step

Complete guide to get your Thorium VNC Browser running in 5 minutes.

## Step 1: Prerequisites Check (1 minute)

Ensure you have these installed:

```bash
# Check Docker
docker --version
# Expected: Docker version 20.10+

# Check Docker Compose
docker-compose --version
# Expected: Docker Compose version 1.29+
```

If not installed, see [Installation Guide](#installation-guide) below.

## Step 2: Clone or Enter Repository (1 minute)

```bash
# If you haven't cloned yet:
git clone https://github.com/russeljimmy/hq9.git
cd hq9

# If already in the repository:
cd /workspaces/hq9
```

## Step 3: Start the Service (2-3 minutes)

### Option A: Quickest (Recommended)

```bash
bash start.sh
```

### Option B: Using Docker Compose

```bash
docker-compose up -d
```

### Option C: Using Make

```bash
make up
```

**Wait 15-20 seconds for services to initialize...**

## Step 4: Access Your Browser (1 minute)

### Method 1: Web Interface (Easiest - No VNC Client Needed)

1. Open your web browser
2. Navigate to: **`http://localhost:6080/vnc.html`**
3. Enter password: **`vnc`**
4. Click "Connect"

### Method 2: VNC Desktop Client

1. Install a VNC client (download links below)
2. Connect to: **`localhost:5900`**
3. Enter password: **`vnc`**

**Recommended VNC Clients:**
- [TigerVNC Viewer](https://tigervnc.org/download.html) - Lightweight
- [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) - Professional
- [Remmina](https://remmina.org/) - Linux (apt install remmina)

## ✅ Verification

### Check if Running

```bash
docker-compose ps
# Should show: thorium-vnc-server  Up X minutes
```

### Test Internet (inside VNC desktop)

1. Once connected, double-click the Chromium/Thorium browser icon
2. Navigate to `https://www.google.com`
3. Try a search to verify it's working

## 🎮 Basic Usage

### Inside VNC Desktop

- **Click to interact** with desktop
- **Right-click** for context menus
- **Keyboard**: Type normally
- **Mouse wheel**: Scroll

### Browser Navigation

- **Click address bar** to enter URLs
- **Type** website address (e.g., `github.com`)
- **Press Enter** to navigate
- **Open new tabs** with Ctrl+T
- **Refresh** with F5 or Ctrl+R

## 🛑 Stopping the Service

### Option 1: Quick Stop

```bash
bash stop.sh
```

### Option 2: Docker Compose Stop

```bash
docker-compose down
```

### Option 3: Using Make

```bash
make down
```

## 🔧 Common Tasks

### View Logs (Troubleshooting)

```bash
docker-compose logs -f
# Press Ctrl+C to exit
```

### Open Shell in Container

```bash
docker-compose exec thorium-vnc-server /bin/bash
```

### Test Internet Connection

```bash
docker-compose exec thorium-vnc-server ping google.com
```

### Change VNC Password

Edit the password in Dockerfile or pass as environment variable:
```bash
docker run -e VNC_PASSWORD=newpass thorium-vnc:latest
```

### Increase Display Resolution

Edit `entrypoint.sh`, change:
```bash
# From:
Xvfb :1 -screen 0 1280x960x24

# To:
Xvfb :1 -screen 0 1920x1080x24
```

Then rebuild:
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## ⚠️ Common Issues & Solutions

### "Connection refused" error

```bash
# Make sure container is running
docker-compose ps

# If not running, start it
docker-compose up -d

# Wait 15 seconds, then try again
```

### "Port already in use"

```bash
# Find what's using port 5900
lsof -i :5900

# Or change port in docker-compose.yml:
# Change: 5900:5900
# To: 5901:5900
```

### Cannot navigate to websites

```bash
# Test DNS inside container
docker-compose exec thorium-vnc-server nslookup google.com

# Test internet access
docker-compose exec thorium-vnc-server ping 8.8.8.8
```

### Browser window not visible

- Verify Xvfb is running: `docker-compose logs`
- Wait 5 more seconds and refresh VNC connection
- Check display resolution in entrypoint.sh

### High memory usage

- Close unnecessary tabs in Chromium
- Restart the container: `docker-compose restart`
- Reduce display resolution

## 📱 Remote Access

### Access from Different Computer on Same Network

```bash
# From remote computer:
# Replace 192.168.1.100 with your server IP

# Web browser:
# http://192.168.1.100:6080/vnc.html

# VNC client:
# Server: 192.168.1.100:5900
```

### Access Over Internet (SSH Tunnel)

```bash
# On your local machine:
ssh -L 6080:localhost:6080 user@server.example.com

# Then access:
# http://localhost:6080/vnc.html
```

## 📚 Documentation Guide

Once you're up and running, explore:

- **[QUICK_START.md](QUICK_START.md)** - Quick reference
- **[README.md](README.md)** - Full documentation
- **[BUILD_GUIDE.md](BUILD_GUIDE.md)** - Build & deployment details
- **[TESTING.md](TESTING.md)** - Testing procedures
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Project overview

## 🚀 Next Steps

### To Customize

1. Edit `docker-compose.yml` for port/resource changes
2. Edit `.env` for environment variables
3. Edit `Dockerfile` for system packages
4. Run `docker-compose build` to rebuild
5. Run `docker-compose up -d` to restart

### To Deploy on Server

1. Clone repo to server: `git clone https://github.com/russeljimmy/hq9.git`
2. Build on server: `docker-compose build --pull`
3. Start: `docker-compose up -d`
4. Access: `http://server-ip:6080/vnc.html`

### To Push to GitHub

```bash
git add .
git commit -m "Initial Thorium VNC setup"
git push origin main
```

### To Create Docker Hub Image

1. Create Docker Hub account
2. Set GitHub secrets (DOCKER_USERNAME, DOCKER_PASSWORD)
3. Tag release: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. Watch GitHub Actions automatically build and publish

## 🎓 Learning Resources

This project demonstrates:

- Docker containerization
- VNC server setup
- Browser automation environments
- Remote desktop technology
- Docker Compose orchestration
- GitHub Actions CI/CD
- Shell scripting
- Linux system administration

## 💡 Pro Tips

1. **Bookmark the VNC URL** - Save `http://localhost:6080/vnc.html` in browser
2. **Use headless mode** - Keep VNC running in background
3. **Multiple sessions** - Can run multiple containers on different ports
4. **Persistent storage** - Browser profile saved in Docker volume
5. **SSH tunnel** - More secure than direct port exposure

## 🆘 Need Help?

### Check Documentation

1. Read [README.md](README.md) - Comprehensive guide
2. See [TESTING.md](TESTING.md) - Testing procedures
3. View [BUILD_GUIDE.md](BUILD_GUIDE.md) - Build issues

### Debugging

```bash
# View full logs
docker-compose logs

# Get system info inside container
docker-compose exec thorium-vnc-server uname -a

# Check running processes
docker-compose exec thorium-vnc-server ps aux
```

### Report Issues

1. Create an issue on GitHub
2. Include error messages
3. Provide your environment (OS, Docker version)
4. Include relevant logs

## ✨ Success Indicators

You'll know everything is working when:

- ✅ Docker container is running (`docker ps` shows it)
- ✅ Can access `http://localhost:6080/vnc.html`
- ✅ VNC password accepted (default: `vnc`)
- ✅ Desktop appears in browser
- ✅ Can open Chromium/Thorium browser
- ✅ Can navigate to websites
- ✅ Internet connectivity works

## 📊 What's Running?

Inside the container:

- **X Server (Xvfb)** - Virtual display
- **OpenBox** - Lightweight window manager
- **TigerVNC** - VNC server for remote access
- **websockify** - VNC to web conversion
- **Chromium** - Web browser
- **PulseAudio** - Audio system
- **D-Bus** - System messaging

## 🎯 Quick Reference Card

```
SERVICE START:        bash start.sh
SERVICE STOP:         bash stop.sh
WEB ACCESS:           http://localhost:6080/vnc.html
PASSWORD:             vnc
VNC CLIENT:           localhost:5900
CHECK STATUS:         docker-compose ps
VIEW LOGS:            docker-compose logs -f
MANAGEMENT MENU:      bash manage.sh
```

---

## Installation Guide

### MacOS

```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop
brew install --cask docker

# Open Docker Desktop from Applications
```

### Windows

1. Download [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
2. Run installer
3. Restart computer
4. Open PowerShell/CMD and verify: `docker --version`

### Linux (Ubuntu/Debian)

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

---

**Now you're ready! Start with `bash start.sh` and access `http://localhost:6080/vnc.html` 🚀**
