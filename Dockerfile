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

ADD start.sh /start.sh

RUN chmod +x /start.sh

# Expose port (Railway will override this)
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Start the service
CMD ["/start.sh"]
