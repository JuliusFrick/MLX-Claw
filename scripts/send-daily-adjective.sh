#!/bin/bash
# Send daily adjective via clawdbot message tool
# This script will be called when clawdbot is active

PENDING_FILE="/root/clawd/.daily-adjective-pending"
TO_SEND_FILE="/root/clawd/.daily-adjective-to-send"

# Check if there's something to send
if [ -f "$TO_SEND_FILE" ]; then
    ADJECTIVE=$(cat "$TO_SEND_FILE")
    if [ -n "$ADJECTIVE" ]; then
        # Send via clawdbot message tool
        # The message tool will be called by clawdbot
        
        echo "READY_TO_SEND:$ADJECTIVE"
        rm "$TO_SEND_FILE"
        exit 0
    fi
fi

# Also check pending (for initial pickup)
if [ -f "$PENDING_FILE" ]; then
    ADJECTIVE=$(cat "$PENDING_FILE")
    if [ -n "$ADJECTIVE" ]; then
        echo "READY_TO_SEND:$ADJECTIVE"
        rm "$PENDING_FILE"
        exit 0
    fi
fi

echo "NO_PENDING"
