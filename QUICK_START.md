# 🚀 Quick Reference Guide

## Start Your VNC Server

### Option 1: Using start.sh (Easiest)
```bash
bash start.sh
```

### Option 2: Using docker-compose
```bash
docker-compose up -d
```

### Option 3: Using Make
```bash
make up
```

---

## Access Your Browser

### 📱 Web Browser (Recommended)
```
http://localhost:6080/vnc.html
Password: vnc
```

### 🖥️ VNC Client
```
Server: localhost:5900
Password: vnc
```

---

## Common Commands

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Get shell access
docker-compose exec thorium-vnc-server /bin/bash

# Stop server
docker-compose down

# Restart server
docker-compose restart

# Use interactive manager
bash manage.sh
```

---

## Files Explained

| File | Purpose |
|------|---------|
| `Dockerfile` | Docker image recipe with VNC + Browser |
| `docker-compose.yml` | Container orchestration config |
| `entrypoint.sh` | Startup entry point for container |
| `start.sh` | Quick start script |
| `manage.sh` | Interactive management menu |
| `README.md` | Full documentation |
| `BUILD_GUIDE.md` | Build & deployment guide |
| `TESTING.md` | Testing procedures |

---

## Troubleshooting

### Container won't start
```bash
docker-compose logs
# Check for errors and run:
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Can't connect
```bash
# Check if container is running
docker-compose ps

# Check if ports are open
lsof -i :5900
lsof -i :6080
```

### Change VNC password
```bash
# Edit Dockerfile or use environment variable
docker run -e VNC_PASSWORD=newpassword thorium-vnc
```

### Increase display resolution
Edit `entrypoint.sh`:
```bash
# Change from 1280x960 to 1920x1080
Xvfb :1 -screen 0 1920x1080x24
```

---

## Performance Tips

1. **Disable extensions** in Chromium
2. **Close unused tabs** to save memory
3. **Use 16-bit color** on slow networks (edit Dockerfile)
4. **Allocate more RAM** if available: `docker run -m 2g thorium-vnc`

---

## Network Setup

### Local Only
- Default setup is localhost only
- Accessible via `http://localhost:6080`

### Remote Access
```bash
# SSH tunnel to remote server
ssh -L 6080:localhost:6080 user@server.com
# Then access: http://localhost:6080/vnc.html
```

### Docker Network
- Custom network: `thorium-network`
- Internal communication via service names

---

## Security Notes

⚠️ **Important**: Default password is `vnc`

For production:
1. Change the password in Dockerfile
2. Use behind reverse proxy (Nginx)
3. Add authentication layer
4. Use HTTPS/SSL
5. Restrict network access

---

## Support

- **README.md** - Full documentation
- **BUILD_GUIDE.md** - Build instructions
- **TESTING.md** - Testing procedures
- **GitHub Issues** - Report problems

---

## Quick Feature Check

- ✅ Lightweight Alpine-based Ubuntu image
- ✅ No crashes - optimized Chromium settings
- ✅ Internet connected - full network access
- ✅ VNC remote desktop - port 5900
- ✅ Web interface - port 6080 (no VNC client needed)
- ✅ Audio support - PulseAudio configured
- ✅ Health checks - automatic monitoring
- ✅ Persistent storage - volumes for profile

---

Last updated: 2026-04-22
