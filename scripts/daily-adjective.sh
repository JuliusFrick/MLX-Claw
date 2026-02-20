#!/bin/bash
# Daily Adjective Sender for Julius
# Runs at 9:00 UTC daily

# Get today's adjective
TODAY=$(date +%Y-%m-%d)
ADJECTIVE=$(grep "$TODAY:" /root/clawd/memory/daily-adjectives.md 2>/dev/null | cut -d':' -f2 | sed 's/^ *//')

if [ -n "$ADJECTIVE" ]; then
    # Send via telegram-cli or curl to Telegram API
    # Using Telegram Bot API
    TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
    CHAT_ID="8077903249"
    
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=Julius - dein tägliches positives Adjektiv: $ADJECTIVE 🖤"
    
    echo "[$(date)] Sent adjective: $ADJECTIVE"
else
    echo "[$(date)] No adjective found for today"
fi
