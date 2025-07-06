#!/bin/sh

# Set default values
PORT=$PORT
VLESS_UUID=$VLESS_UUID
REALITY_PRIVATE_KEY=$REALITY_PRIVATE_KEY
REALITY_SHORT_ID=$REALITY_SHORT_ID

echo "Starting Xray on port $PORT"
echo "UUID: $VLESS_UUID"
echo "Short ID: $REALITY_SHORT_ID"

# Update config with environment variables
sed -i "s/8080/$PORT/g" /etc/xray/config.json
sed -i "s/your-uuid-here/$VLESS_UUID/g" /etc/xray/config.json
sed -i "s/your-private-key-here/$REALITY_PRIVATE_KEY/g" /etc/xray/config.json
sed -i "s/your-short-id-here/$REALITY_SHORT_ID/g" /etc/xray/config.json

# Start Xray
exec /usr/local/bin/xray -config /etc/xray/config.json
