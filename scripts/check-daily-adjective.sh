#!/bin/bash
# Check for pending daily adjective and send via clawdbot message tool

PENDING_FILE="/root/clawd/.daily-adjective-pending"

if [ -f "$PENDING_FILE" ]; then
    ADJECTIVE=$(cat "$PENDING_FILE")
    
    if [ -n "$ADJECTIVE" ]; then
        # Create a message file for clawdbot to pick up
        #clawdbot message --target 8077903249 --message "Julius - dein tägliches positives Adjektiv: $ADJECTIVE 🖤"
        
        echo "SEND:$ADJECTIVE" > /root/clawd/.daily-adjective-to-send
        
        # Remove pending file (it will be picked up)
        rm "$PENDING_FILE"
        
        echo "[$(date)] Ready to send: $ADJECTIVE"
    fi
else
    echo "[$(date)] No pending adjective"
fi
