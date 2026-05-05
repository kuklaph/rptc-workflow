# Discord Notification Patterns

Quick reference for common notification scenarios.

## Using Environment Variable or Settings.json (Recommended)

Provider-neutral option:

```bash
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/..."
WEBHOOK_URL="$DISCORD_WEBHOOK"
```

If `./.claude/settings.json` or `./.codex/settings.json` contains your webhook URL:

```json
{
  "discord_webhook_url": "https://discord.com/api/webhooks/..."
}
```

Read it in bash commands:
```bash
SETTINGS_FILE="./.codex/settings.json"  # Claude: ./.claude/settings.json
WEBHOOK_URL=$(grep -o '"discord_webhook_url"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_FILE" | cut -d'"' -f4)
```

Then use `$WEBHOOK_URL` in all commands below.

## Direct Curl Commands (No Script Needed)

### Simple Text Message

```bash
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "Your message here"}'
```

### Message with Embed (Recommended)

```bash
curl -X POST "WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "RPTC",
    "embeds": [{
      "description": "Your message here",
      "color": 3447003,
      "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
    }]
  }'
```

## Common Notification Scenarios

### Task Completed (Green)

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"username":"RPTC","embeds":[{"description":"✅ Task completed successfully","color":65280,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

### Task Failed (Red)

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"username":"RPTC","embeds":[{"description":"❌ Task failed","color":16711680,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

### Processing Complete (Blue)

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"username":"RPTC","embeds":[{"description":"🔄 Processing complete","color":3447003,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

### Warning (Yellow)

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"username":"RPTC","embeds":[{"description":"⚠️ Warning: Check results","color":16776960,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

## Color Reference

- **Green (Success)**: 65280
- **Red (Error)**: 16711680
- **Blue (Info)**: 3447003
- **Yellow (Warning)**: 16776960
- **Purple**: 10181046
- **Orange**: 16744192

## Template with Dynamic Content

```bash
TASK="Document conversion"
STATUS="completed"
DETAILS="Processed 15 files"

curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{
  "username": "RPTC",
  "embeds": [{
    "title": "'"$TASK"'",
    "description": "Status: '"$STATUS"'\n'"$DETAILS"'",
    "color": 65280,
    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
  }]
}'
```

## Rich Embed with Fields

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{
  "username": "RPTC",
  "embeds": [{
    "title": "Task Summary",
    "description": "Operation completed",
    "color": 65280,
    "fields": [
      {"name": "Files Processed", "value": "25", "inline": true},
      {"name": "Duration", "value": "2m 15s", "inline": true},
      {"name": "Status", "value": "Success", "inline": true}
    ],
    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
  }]
}'
```

## Multi-line Messages

Use `\n` for line breaks:

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{
  "username": "RPTC",
  "embeds": [{
    "description": "✅ Build completed\n\n**Summary:**\n- Tests passed: 45/45\n- Build time: 3m 12s\n- Branch: main",
    "color": 65280,
    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
  }]
}'
```

## Error Handling

Always check curl exit code:

```bash
if curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" \
  -d '{"content": "Notification"}' --silent --show-error --fail; then
  echo "Notification sent"
else
  echo "Failed to send notification"
fi
```

## Rate Limits

Discord webhooks allow **30 requests per minute**. For multiple notifications:

```bash
# Send notification
curl -X POST "$WEBHOOK_URL" ...

# Wait between notifications if sending multiple
sleep 2

# Send next notification
curl -X POST "$WEBHOOK_URL" ...
```

## Configuration Patterns

### Recommended: Environment Variable or Settings.json

For provider-neutral use, prefer `DISCORD_WEBHOOK`. For provider-local settings, use `./.claude/settings.json` in Claude or `./.codex/settings.json` in Codex:

```bash
# Create settings file (Codex shown; Claude uses ./.claude/settings.json)
SETTINGS_DIR="./.codex"
mkdir -p "$SETTINGS_DIR"
cat > "$SETTINGS_DIR/settings.json" << 'EOF'
{
  "discord_webhook_url": "https://discord.com/api/webhooks/..."
}
EOF

# Read and use
WEBHOOK_URL=$(grep -o '"discord_webhook_url"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_DIR/settings.json" | cut -d'"' -f4)
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" \
  -d '{"content": "Message"}'
```

### Alternative: Environment Variable

```bash
# Set once (persists for shell session)
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/..."

# Use in commands
curl -X POST "$DISCORD_WEBHOOK" -H "Content-Type: application/json" \
  -d '{"content": "Message"}'
```
