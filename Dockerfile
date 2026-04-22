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

# Create VNC startup script
RUN mkdir -p /etc/vnc
COPY vnc_startup.sh /etc/vnc/
RUN chmod +x /etc/vnc/vnc_startup.sh

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

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:6080/vnc.html || exit 1

# Start VNC server
ENTRYPOINT ["/entrypoint.sh"]
