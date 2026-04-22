#!/bin/bash

# Entrypoint script for VNC + Browser container
set -e

echo "🚀 Starting Thorium Browser VNC Server..."

# Start PulseAudio daemon for audio support
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true

# Ensure display is set
export DISPLAY=:1
export VNCDESKTOP="Thorium Browser Desktop"
export USER=root
export HOME=/root

# Clean up any stale X locks
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# Create X virtual framebuffer
echo "📺 Starting Xvfb..."
Xvfb :1 -screen 0 1280x960x24 -ac +extension RANDR +extension GLX 2>/dev/null &
XVFB_PID=$!

# Wait for X to start
sleep 3

# Start OpenBox window manager
echo "🪟 Starting Window Manager..."
openbox --replace 2>/dev/null &
OPENBOX_PID=$!

# Wait for OpenBox
sleep 2

# Start VNC server using x11vnc (attaches to existing X display)
echo "🖥️ Starting VNC Server on port 5900..."
x11vnc -display :1 \
    -forever \
    -shared \
    -nopw \
    -rfbport 5900 \
    -geometry 1280x960 \
    -rfbauth /root/.vnc/passwd \
    -desktop "Thorium Browser" \
    2>&1 &
VNC_X11VNC_PID=$!

# Wait for x11vnc to start and listen on port 5900
echo "⏳ Waiting for VNC server to be ready..."
for i in {1..30}; do
    if ps aux | grep -q "[x]11vnc -display"; then
        echo "✓ VNC server (x11vnc) detected"
        sleep 2
        break
    fi
    echo "   Attempt $i/30..."
    sleep 1
done

sleep 1

# Start noVNC web interface for browser access
echo "🌐 Starting noVNC Web Interface on port 6080..."
websockify --web=/usr/share/novnc --verbose 6080 localhost:5900 &
NOVNC_PID=$!

# Apply display settings
sleep 1
xrandr -s 1280x960 2>/dev/null || true

# Launch Thorium/Chromium Browser with stability flags
echo "🌍 Starting Thorium Browser..."
CHROMIUM_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-port=9222 --no-first-run --no-default-browser-check --disable-sync --disable-default-apps --disable-component-extensions-with-background-pages --disable-pings --disable-hang-monitor --disable-prompt-on-repost --no-service-autorun --disable-background-networking --disable-client-side-phishing-detection --disable-popup-blocking --disable-preconnect"

# Start Chromium in the background
chromium-browser $CHROMIUM_FLAGS 2>/dev/null || chromium $CHROMIUM_FLAGS 2>/dev/null &
BROWSER_PID=$!

# Keep running
echo "✅ VNC Server is running!"
echo "📍 VNC Connection: localhost:5900 (password: vnc)"
echo "🌐 Web Browser: http://localhost:6080/vnc.html"
echo "🔧 Chromium Remote Debug: http://localhost:9222"
echo ""

# Keep the container alive
tail -f /dev/null
