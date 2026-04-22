#!/bin/sh
# VNC Server startup script

# Set up VNC server configuration
echo "Configuring VNC Server..."

# Create VNC xstartup script if it doesn't exist
cat > /root/.vnc/xstartup << 'EOF'
#!/bin/sh
# VNC xstartup script

# Start essential services
dbus-launch --exit-with-session &

# Set up keyboard and mouse
setxkbmap us
xsetroot -solid grey

# Start window manager
exec openbox &

# Wait indefinitely
while true; do sleep 3600; done
EOF

chmod +x /root/.vnc/xstartup

exit 0
