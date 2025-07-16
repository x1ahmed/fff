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

/usr/local/bin/xray -config /etc/xray/config.json &

sleep 2

# Create Serveo tunnel on random port and extract tunnel info
echo "Creating Serveo tunnel..."
ssh -o StrictHostKeyChecking=no -o LogLevel=ERROR -R 0:localhost:$PORT serveo.net | tee /tmp/serveo.log &
sleep 5

# Show forwarded address
FORWARD_ADDR=$(grep -oE "Forwarding TCP connections from serveo.net:[0-9]+" /tmp/serveo.log | awk '{print $5}')
if [ -n "$FORWARD_ADDR" ]; then
    echo "✅ Serveo Tunnel Created:"
    echo "➡️  $FORWARD_ADDR"
else
    echo "❌ Failed to create tunnel"
    cat /tmp/serveo.log
fi

# Keep container alive
tail -f /dev/null
