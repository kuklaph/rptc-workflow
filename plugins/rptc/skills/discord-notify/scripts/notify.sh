#!/bin/bash
# Send a notification to Discord webhook
# Usage: ./notify.sh [webhook_url] <message> [username] [color]
# If webhook_url is not provided, reads DISCORD_WEBHOOK or a provider settings file.

extract_webhook() {
    grep -o '"discord_webhook_url"[[:space:]]*:[[:space:]]*"[^"]*"' "$1" | cut -d'"' -f4
}

SETTINGS_WEBHOOK="$DISCORD_WEBHOOK"
SETTINGS_SOURCE="DISCORD_WEBHOOK"

if [ -z "$SETTINGS_WEBHOOK" ]; then
    for SETTINGS_FILE in \
        "./.claude/settings.json" \
        "./.codex/settings.json" \
        "$HOME/.claude/settings.json" \
        "$HOME/.codex/settings.json"; do
        if [ -f "$SETTINGS_FILE" ]; then
            SETTINGS_WEBHOOK=$(extract_webhook "$SETTINGS_FILE")
            if [ -n "$SETTINGS_WEBHOOK" ]; then
                SETTINGS_SOURCE="$SETTINGS_FILE"
                break
            fi
        fi
    done
fi

# Determine if first arg is webhook URL or message
if [[ "$1" =~ ^https://discord\.com/api/webhooks/ ]]; then
    # First arg is webhook URL
    WEBHOOK_URL="$1"
    MESSAGE="$2"
    USERNAME="${3:-RPTC}"
    COLOR="${4:-3447003}"
else
    # First arg is message, use settings.json webhook
    WEBHOOK_URL="${SETTINGS_WEBHOOK}"
    MESSAGE="$1"
    USERNAME="${2:-RPTC}"
    COLOR="${3:-3447003}"
fi

# Validate we have required parameters
if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: No webhook URL provided and none found in DISCORD_WEBHOOK or provider settings"
    echo ""
    echo "Usage: $0 [webhook_url] <message> [username] [color]"
    echo ""
    echo "Examples:"
    echo "  $0 'Task completed'  # Uses webhook from DISCORD_WEBHOOK or settings.json"
    echo "  $0 https://discord.com/api/webhooks/... 'Task completed'"
    echo ""
    echo "To use settings.json, create ./.claude/settings.json or ./.codex/settings.json with:"
    echo '  {"discord_webhook_url": "https://discord.com/api/webhooks/..."}'
    exit 1
fi

if [ -z "$MESSAGE" ]; then
    echo "Error: Message is required"
    echo "Usage: $0 [webhook_url] <message> [username] [color]"
    exit 1
fi

# Create JSON payload with embed
JSON_PAYLOAD=$(cat <<EOF
{
  "username": "$USERNAME",
  "embeds": [{
    "description": "$MESSAGE",
    "color": $COLOR,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
  }]
}
EOF
)

# Send to Discord
curl -X POST \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "$WEBHOOK_URL" \
  --silent \
  --show-error \
  --fail

if [ $? -eq 0 ]; then
    echo "✓ Notification sent successfully"
    exit 0
else
    echo "✗ Failed to send notification"
    exit 1
fi
