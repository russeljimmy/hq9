#!/bin/sh

# Entrypoint script for VNC + Browser container

set -e

echo "🚀 Starting Thorium Browser VNC Server..."

# Start PulseAudio daemon for audio support
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true

# Ensure display is set
export DISPLAY=:1
export VNCDESKTOP="Thorium Browser Desktop"

# Create X virtual framebuffer
echo "📺 Starting Xvfb..."
Xvfb :1 -screen 0 1280x960x24 -ac +extension RANDR +extension GLX &
XVFB_PID=$!

# Wait for X to start
sleep 2

# Start OpenBox window manager
echo "🪟 Starting Window Manager..."
openbox --replace &
OPENBOX_PID=$!

# Wait for OpenBox
sleep 1

# Start VNC server
echo "🖥️ Starting VNC Server on port 5900..."
vncserver :1 -geometry 1280x960 -depth 24 -rfbport 5900 \
    -authfile /root/.vnc/passwd \
    -SecurityTypes VncAuth,None 2>&1 &
VNC_PID=$!

# Wait for VNC to stabilize
sleep 2

# Start noVNC web interface for browser access
echo "🌐 Starting noVNC Web Interface on port 6080..."
cd /root/.novnc 2>/dev/null || cd /usr/share/novnc || {
    echo "Installing noVNC..."
    apk add --no-cache novnc websockify
}
websockify --web=/usr/share/novnc 6080 localhost:5900 &
NOVNC_PID=$!

# Apply display settings
sleep 1
xrandr -s 1280x960 2>/dev/null || true

# Launch Thorium/Chromium Browser
echo "🌍 Starting Thorium Browser..."
CHROMIUM_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-port=9222"
chromium $CHROMIUM_FLAGS &
BROWSER_PID=$!

# Function to handle signal termination
cleanup() {
    echo "🛑 Shutting down services..."
    kill $BROWSER_PID 2>/dev/null || true
    kill $NOVNC_PID 2>/dev/null || true
    vncserver -kill :1 2>/dev/null || true
    kill $OPENBOX_PID 2>/dev/null || true
    kill $XVFB_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

# Keep running
echo "✅ VNC Server is running!"
echo "📍 VNC Connection: localhost:5900 (password: vnc)"
echo "🌐 Web Browser: http://localhost:6080/vnc.html"
echo ""

# Wait for processes
wait $BROWSER_PID 2>/dev/null || wait
