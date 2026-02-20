#!/bin/bash
# Prepare daily adjective for Julius
# Runs at 9:00 UTC via cron

TODAY=$(date +%Y-%m-%d)
ADJECTIVE=$(grep "$TODAY:" /root/clawd/memory/daily-adjectives.md 2>/dev/null | cut -d':' -f2- | sed 's/^ *//')

if [ -n "$ADJECTIVE" ]; then
    echo "$ADJECTIVE" > /root/clawd/.daily-adjective-pending
    echo "[$(date)] Prepared adjective: $ADJECTIVE"
else
    echo "[$(date)] No adjective found for $TODAY"
fi
