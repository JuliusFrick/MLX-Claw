# Heartbeat-Check aktiviert

# Check täglich um ~9:00 UTC (sobald clawdbot aktiv ist)

# Daily Adjective Check
1. Prüfe ob /root/clawd/.daily-adjective-pending existiert
2. Falls ja: Sende adjective an Julius via Telegram
3. Lösche die pending-Datei

# Format der pending-Datei:
# [Adjektiv]
# Beispiel: Kreativ
