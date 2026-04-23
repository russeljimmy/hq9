#!/bin/bash

# Entrypoint script for VNC + Browser container
# Fixed to properly initialize X11, OpenBox, and Chromium browser

echo "🚀 Starting Thorium Browser VNC Server..."

# Ensure display is set
export DISPLAY=:1
export VNCDESKTOP="Thorium Browser Desktop"
export USER=root
export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Start PulseAudio daemon for audio support
echo "🔊 Starting PulseAudio..."
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true

# Clean up any stale X locks
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# Create X virtual framebuffer
echo "📺 Starting Xvfb..."
Xvfb :1 -screen 0 1280x960x24 -ac +extension RANDR +extension GLX 2>&1 &
XVFB_PID=$!
echo "   Xvfb PID: $XVFB_PID"

# Wait for Xvfb to start properly
sleep 3

# Verify Xvfb is running
if ! ps -p $XVFB_PID > /dev/null; then
    echo "❌ Xvfb failed to start"
    exit 1
fi
echo "✓ Xvfb is running"

# Start dbus-daemon for X11 session
echo "📡 Starting DBus daemon..."
dbus-daemon --system --nofork --nopidfile 2>/dev/null &
sleep 1

# Start OpenBox window manager
echo "🪟 Starting Window Manager (OpenBox)..."
openbox --replace --config-file /root/.config/openbox/rc.xml 2>&1 &
OPENBOX_PID=$!
echo "   OpenBox PID: $OPENBOX_PID"

# Wait longer for OpenBox to fully initialize and decorate windows
echo "⏳ Waiting for OpenBox to initialize..."
sleep 5

# Verify OpenBox is running
if ! ps -p $OPENBOX_PID > /dev/null; then
    echo "❌ OpenBox failed to start"
    exit 1
fi
echo "✓ OpenBox is running"

# Apply display settings
echo "🎨 Applying display settings..."
xrandr -s 1280x960 2>/dev/null || true
xsetroot -solid "#2c3e50" 2>/dev/null || true

# Verify X11 display is ready
echo "✓ X11 display ready at $DISPLAY"

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
    -loop100 \
    -scale 1.0 \
    2>&1 &
VNC_X11VNC_PID=$!
echo "   x11vnc PID: $VNC_X11VNC_PID"

# Wait for x11vnc to start and listen on port 5900
echo "⏳ Waiting for VNC server to be ready..."
for i in {1..30}; do
    if ps -p $VNC_X11VNC_PID > /dev/null && netstat -tuln 2>/dev/null | grep -q ":5900"; then
        echo "✓ VNC server is ready (port 5900)"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  VNC server timeout, continuing anyway..."
    fi
    sleep 1
done

# Start noVNC web interface for browser access
echo "🌐 Starting noVNC Web Interface on port 6080..."
websockify --web=/usr/share/novnc 6080 localhost:5900 2>&1 &
NOVNC_PID=$!
echo "   noVNC PID: $NOVNC_PID"

# Wait for noVNC to be ready
sleep 2

# IMPORTANT: Wait a bit more to ensure OpenBox window manager is fully ready
# This is critical for the browser window to appear properly
echo "⏳ Final initialization checks..."
sleep 4

# Launch Thorium/Chromium Browser as a windowed application
echo "🌍 Starting Thorium Browser..."

# Use a wrapper script to ensure browser runs with proper X11 decorations
cat > /tmp/launch_browser.sh << 'BROWSER_EOF'
#!/bin/bash
export DISPLAY=:1
export HOME=/root
sleep 1

CHROMIUM_FLAGS="--new-window \
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --remote-debugging-port=9222 \
    --no-first-run \
    --no-default-browser-check \
    --disable-sync \
    --disable-default-apps \
    --disable-component-extensions-with-background-pages \
    --disable-pings \
    --disable-hang-monitor \
    --disable-prompt-on-repost \
    --no-service-autorun \
    --disable-background-networking \
    --disable-client-side-phishing-detection \
    --disable-popup-blocking \
    --disable-preconnect \
    --disable-extensions \
    --disable-plugins \
    --enable-features=NetworkService,NetworkServiceInProcess \
    about:blank"

# Execute browser with proper window management
exec chromium-browser $CHROMIUM_FLAGS 2>&1 | tee -a /tmp/chromium.log
BROWSER_EOF

chmod +x /tmp/launch_browser.sh

# Start browser launcher in background
(/tmp/launch_browser.sh &) > /dev/null 2>&1
BROWSER_PID=$!
echo "   Chromium Browser PID: $BROWSER_PID"

# Give browser time to initialize
sleep 3

# Keep running
echo ""
echo "✅ VNC Server is running!"
echo "📍 VNC Connection Details:"
echo "   - Server: localhost:5900"
echo "   - Password: vnc"
echo "🌐 Web Browser: http://localhost:6080/vnc.html"
echo "🔧 Chromium Remote Debug: http://localhost:9222"
echo "💡 Desktop Application: Right-click on desktop for menu or click Thorium icon"
echo ""
echo "🔍 Process Status:"
ps aux | grep -E "[X]vfb|[o]penbox|[x]11vnc|[w]ebsockify|[c]hromium" || true
echo ""

# Keep the container alive and monitor processes
cleanup() {
    echo "Shutting down..."
    kill $BROWSER_PID 2>/dev/null || true
    kill $NOVNC_PID 2>/dev/null || true
    kill $VNC_X11VNC_PID 2>/dev/null || true
    kill $OPENBOX_PID 2>/dev/null || true
    kill $XVFB_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

# Monitor and restart if processes die
while true; do
    # Check if main processes are still running
    if ! ps -p $XVFB_PID > /dev/null 2>&1; then
        echo "⚠️  Xvfb died, stopping container..."
        cleanup
    fi
    
    if ! ps -p $OPENBOX_PID > /dev/null 2>&1; then
        echo "⚠️  OpenBox died, restarting..."
        openbox --replace --config-file /root/.config/openbox/rc.xml 2>&1 &
        OPENBOX_PID=$!
    fi
    
    if ! ps -p $VNC_X11VNC_PID > /dev/null 2>&1; then
        echo "⚠️  x11vnc died, restarting..."
        x11vnc -display :1 -forever -shared -nopw -rfbport 5900 -geometry 1280x960 -rfbauth /root/.vnc/passwd -desktop "Thorium Browser" 2>&1 &
        VNC_X11VNC_PID=$!
    fi
    
    sleep 10
done
