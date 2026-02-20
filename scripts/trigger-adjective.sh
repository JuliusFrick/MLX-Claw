#!/bin/bash
# Trigger clawdbot to send adjective via message tool
# This can be called from cron

TODAY=$(date +%Y-%m-%d)
ADJECTIVE=$(grep "$TODAY:" /root/clawd/memory/daily-adjectives.md 2>/dev/null | cut -d':' -f2- | sed 's/^ *//')

if [ -n "$ADJECTIVE" ]; then
    # Create a trigger file that clawdbot can check
    echo "$ADJECTIVE" > /root/clawd/.daily-adjective-trigger
    echo "[$(date)] Trigger created: $ADJECTIVE"
fi
