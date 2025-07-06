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

ARG PORT=17306
ARG VLESS_UUID=8442ff27-8e79-4f27-b4d2-c3e6447789ea
ARG REALITY_PRIVATE_KEY=8GXPCvZ4ty3uEKxexznrZvCSo3NqYwzKY5dzbaQGWVM
ARG REALITY_SHORT_ID=8236

ENV PORT=$PORT
ENV VLESS_UUID=$VLESS_UUID
ENV REALITY_PRIVATE_KEY=$REALITY_PRIVATE_KEY
ENV REALITY_SHORT_ID=$REALITY_SHORT_ID

# Copy configuration file
COPY config.json /etc/xray/config.json

ADD start.sh /start.sh

RUN chmod +x /start.sh

# Expose port (Railway will override this)
EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Start the service
CMD ["/start.sh"]
