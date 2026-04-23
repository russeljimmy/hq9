#!/bin/bash
# VNC Server startup script - xstartup replacement
# This script is called by x11vnc/Xvfb to start the user session

echo "🚀 VNC Session Starting..."

# Set up core environment
export DISPLAY=:1
export USER=root
export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Start essential services
echo "📡 Starting session bus..."
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS

# Set up keyboard and mouse
echo "⌨️  Configuring keyboard..."
setxkbmap -layout us -model pc104

# Set a nice background
echo "🎨 Setting background..."
xsetroot -solid "#2c3e50"

# Start window manager if not already running
if ! pgrep -x openbox > /dev/null; then
    echo "🪟 Starting OpenBox..."
    exec openbox --config-file /root/.config/openbox/rc.xml &
fi

# Start Chromium/Thorium browser
echo "🌍 Starting Thorium Browser..."
sleep 2

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
    --disable-extensions \
    --disable-plugins \
    about:blank"

# Launch browser
chromium-browser $CHROMIUM_FLAGS 2>&1 | tee -a /tmp/chromium.log &
BROWSER_PID=$!

echo "✅ VNC session ready"
echo "   Browser PID: $BROWSER_PID"

# Keep the session alive
while sleep 3600; do :; done
