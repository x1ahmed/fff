FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    curl \
    unzip \
    ca-certificates \
    openssl \
    jq

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

# Create startup script with environment variable support
RUN echo '#!/bin/sh' > /start.sh && \
    echo '' >> /start.sh && \
    echo '# Set default values' >> /start.sh && \
    echo 'PORT=${PORT:-8080}' >> /start.sh && \
    echo 'VLESS_UUID=${VLESS_UUID:-"your-uuid-here"}' >> /start.sh && \
    echo 'REALITY_PRIVATE_KEY=${REALITY_PRIVATE_KEY:-"your-private-key-here"}' >> /start.sh && \
    echo 'REALITY_SHORT_ID=${REALITY_SHORT_ID:-"your-short-id-here"}' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "Starting Xray on port $PORT with PlayStation SNI..."' >> /start.sh && \
    echo 'echo "UUID: ${VLESS_UUID:0:8}..."' >> /start.sh && \
    echo 'echo "Short ID: $REALITY_SHORT_ID"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Update config with environment variables' >> /start.sh && \
    echo 'sed -i "s/8080/$PORT/g" /etc/xray/config.json' >> /start.sh && \
    echo 'sed -i "s/your-uuid-here/$VLESS_UUID/g" /etc/xray/config.json' >> /start.sh && \
    echo 'sed -i "s/your-private-key-here/$REALITY_PRIVATE_KEY/g" /etc/xray/config.json' >> /start.sh && \
    echo 'sed -i "s/your-short-id-here/$REALITY_SHORT_ID/g" /etc/xray/config.json' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start Xray' >> /start.sh && \
    echo 'exec /usr/local/bin/xray -config /etc/xray/config.json' >> /start.sh

RUN chmod +x /start.sh

# Expose port (Railway will override this)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/health || exit 1

# Start the service
CMD ["/start.sh"]
