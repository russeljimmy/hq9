# Lightweight Linux VNC with Thorium Browser - Using Ubuntu for stability
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core X11 and VNC components
    xvfb \
    tightvncserver \
    x11vnc \
    novnc \
    websockify \
    # Window manager
    openbox \
    # Required for audio
    pulseaudio \
    libasound2t64 \
    alsa-utils \
    # Browser and its dependencies
    chromium-browser \
    # Essential utilities
    fonts-liberation \
    ca-certificates \
    curl \
    wget \
    git \
    netstat-nat \
    net-tools \
    # X11 utilities
    x11-utils \
    x11-xserver-utils \
    xserver-xorg-core \
    # Network and system tools
    dbus \
    dbus-x11 \
    net-tools \
    iputils-ping \
    # C libraries for browser stability
    libc6 \
    libstdc++6 \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /root/.vnc \
    && mkdir -p /root/.config/openbox

# Create VNC password file (default password: vnc)
RUN echo "vnc" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Create xstartup script for VNC sessions
RUN cat > /root/.vnc/xstartup << 'XSTARTUP_EOF'
#!/bin/bash
# VNC xstartup script

export DISPLAY=:1
export USER=root
export HOME=/root
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Start essential services
eval $(dbus-launch --sh-syntax)

# Set up keyboard and mouse
setxkbmap -layout us -model pc104
xsetroot -solid "#2c3e50"

# Start window manager
openbox --config-file /root/.config/openbox/rc.xml &
sleep 3

# Start Chromium browser
CHROMIUM_FLAGS="--new-window --no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-port=9222 --no-first-run --no-default-browser-check --disable-sync --disable-extensions --disable-plugins about:blank"
chromium-browser $CHROMIUM_FLAGS 2>&1 | tee -a /tmp/chromium.log &

# Keep running
while sleep 3600; do :; done
XSTARTUP_EOF
RUN chmod +x /root/.vnc/xstartup

# Copy VNC startup script  
COPY vnc_startup.sh /etc/vnc/
RUN mkdir -p /etc/vnc && chmod +x /etc/vnc/vnc_startup.sh

# Copy OpenBox configuration
COPY openbox_rc.xml /root/.config/openbox/rc.xml

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create proper noVNC index file with VNC connection defaults
RUN mkdir -p /root/.novnc && cat > /usr/share/novnc/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thorium VNC</title>
</head>
<body style="margin: 0; padding: 0; overflow: hidden;">
    <script>
        // Redirect to vnc.html with proper parameters
        window.location.href = '/vnc.html?path=?token=1234&autoconnect=true&password=vnc';
    </script>
</body>
</html>
EOF

# Expose VNC port
EXPOSE 5900

# Expose noVNC web interface port
EXPOSE 6080

# Expose Chromium remote debugging port
EXPOSE 9222

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:6080/vnc.html || exit 1

# Start VNC server with entrypoint
ENTRYPOINT ["/entrypoint.sh"]
