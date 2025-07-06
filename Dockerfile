FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    curl \
    unzip \
    ca-certificates \
    openssl

# Download and install Xray
RUN curl -Lo xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip xray.zip && \
    chmod +x xray && \
    mv xray /usr/local/bin/xray && \
    rm -rf xray.zip geoip.dat geosite.dat

# Create config directory
RUN mkdir -p /etc/xray

# Copy configuration file
COPY config.json /etc/xray/config.json

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "Starting Xray with Reality protocol..."' >> /start.sh && \
    echo 'exec /usr/local/bin/xray -config /etc/xray/config.json' >> /start.sh && \
    chmod +x /start.sh

# Expose port
EXPOSE 443

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:443 || exit 1

# Start the service
CMD ["/start.sh"]
