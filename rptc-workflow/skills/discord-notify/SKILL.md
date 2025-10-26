---
name: discord-notify
description: Automatically send Discord notifications when completing tasks, processing files, or encountering errors. Use when the user requests to be notified upon task completion, or when completing long-running operations where a notification would be helpful. Uses curl (no external dependencies).
license: MIT
---

# Discord Notify

Send automatic Discord notifications when tasks complete. Uses curl directly - no Python or external dependencies needed.

## When to Send Notifications

Automatically send notifications in these scenarios:

### Always Notify

- **Task explicitly requests notification**: "Process these files and let me know when done"
- **Long-running operations complete**: File processing, data analysis, bulk operations (>5 files or >2 minutes)
- **Batch operations finish**: Multiple files converted, batch processing complete
- **Scheduled or background tasks complete**: Automation workflows, cron-style tasks

### Consider Notifying

- **Complex multi-step workflows finish**: RPTC workflow completion, complex builds
- **Error occurs during unattended operation**: Failed automation, processing errors
- **Significant milestone reached**: "Processed 100 of 200 files"

### Don't Notify

- **Simple queries or explanations**: Questions, documentation, quick edits
- **Interactive conversations**: User is actively participating
- **Trivial tasks**: Single file edits, simple calculations

## Configuration

### Option 1: Settings File (Recommended)

Create `./.claude/settings.json` with your webhook URL:

```json
{
  "discord_webhook_url": "https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN"
}
```

Once configured, Claude can send notifications without needing the webhook URL each time. A template is available at `assets/settings.json.template`.

### Option 2: Provide Webhook URL Per Task

Give Claude the webhook URL for each task that needs notification.

## Quick Start

### Method 1: Settings File (After Configuration)

```bash
# Read webhook from settings.json and send notification
WEBHOOK_URL=$(grep -o '"discord_webhook_url"[[:space:]]*:[[:space:]]*"[^"]*"' ./.claude/settings.json | cut -d'"' -f4)

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"username":"Claude","embeds":[{"description":"✅ Task completed","color":65280,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

Or use the bash script (reads from settings.json automatically):
```bash
bash scripts/notify.sh "Task completed"
```

### Method 2: With Explicit Webhook URL

```bash
# Provide webhook URL directly
curl -X POST "https://discord.com/api/webhooks/..." \
  -H "Content-Type: application/json" \
  -d '{"username":"Claude","embeds":[{"description":"✅ Task completed","color":65280,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

Or with bash script:
```bash
bash scripts/notify.sh "https://discord.com/api/webhooks/..." "Task completed"
```

## Common Notification Patterns

### Task Completed Successfully

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"username":"Claude","embeds":[{"description":"✅ Task completed successfully","color":65280,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

### Task Failed

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"username":"Claude","embeds":[{"description":"❌ Task failed: [reason]","color":16711680,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

### Processing Complete with Details

```bash
DETAILS="Processed 15 files in 2m 30s"
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{
  "username":"Claude",
  "embeds":[{
    "description":"🔄 Processing complete\n\n'"$DETAILS"'",
    "color":3447003,
    "timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
  }]
}'
```

### Warning or Partial Success

```bash
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{"username":"Claude","embeds":[{"description":"⚠️ Task completed with warnings\n\n[details]","color":16776960,"timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}]}'
```

## Usage Workflow

1. **Complete the task** as requested
2. **Determine if notification is warranted** (see "When to Send Notifications")
3. **Choose appropriate message and color**:
   - Green (65280): Success
   - Red (16711680): Error
   - Blue (3447003): Info/Complete
   - Yellow (16776960): Warning
4. **Send notification** using curl command
5. **Confirm to user** that notification was sent

## Example Integration

```bash
# User asks: "Convert these 20 PDFs to images and let me know when done"

# 1. Process files
for pdf in *.pdf; do
    convert_pdf_to_images "$pdf"
done

# 2. Send notification
curl -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d '{
  "username":"Claude",
  "embeds":[{
    "title":"PDF Conversion Complete",
    "description":"✅ Converted 20 PDFs to images\n\nAll files are ready in /outputs",
    "color":65280,
    "fields":[
      {"name":"Files Processed","value":"20","inline":true},
      {"name":"Status","value":"Success","inline":true}
    ],
    "timestamp":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"
  }]
}'

# 3. Inform user
echo "Notification sent to Discord"
```

## Setup Instructions

### Step 1: Get Webhook URL

The user needs to:
1. Open Discord → Channel Settings → Integrations → Webhooks
2. Create a new webhook or copy existing webhook URL
3. The URL looks like: `https://discord.com/api/webhooks/123456/AbCdEf...`

### Step 2: Configure Settings File (Recommended)

Create `./.claude/settings.json`:

```bash
cat > ./.claude/settings.json << 'EOF'
{
  "discord_webhook_url": "https://discord.com/api/webhooks/YOUR_ACTUAL_URL_HERE"
}
EOF
```

Or copy and edit the template:
```bash
cp assets/settings.json.template ./.claude/settings.json
# Then edit ./.claude/settings.json with actual webhook URL
```

Once configured, Claude can send notifications without needing the URL repeatedly.

### Alternative: Provide URL Per Task

Skip settings.json and provide webhook URL for each task that needs notification.

## Best Practices

### Security
- Store webhook URL in `./.claude/settings.json` for convenience
- Don't log webhook URLs in outputs
- URLs are sensitive and should be treated as secrets
- Settings.json is local to Claude's environment and not shared

### Message Quality
- Use clear, actionable messages
- Include relevant details (file count, duration, errors)
- Use appropriate emoji: ✅ ❌ 🔄 ⚠️ 📊
- Include timestamps (automatically added)

### Rate Limits
- Discord allows 30 requests/minute per webhook
- For multiple notifications, space them 2+ seconds apart
- Batch updates when possible

### Error Handling
- Always use `--silent --show-error --fail` flags with curl
- Check exit code before confirming notification sent
- If notification fails, inform user in response

## Advanced Patterns

See `references/patterns.md` for:
- Rich embeds with multiple fields
- Multi-line message formatting
- Dynamic content templates
- Error handling patterns
- Environment variable usage

## Troubleshooting

**Notification not appearing**: Check webhook URL is correct and channel exists

**400 Bad Request**: JSON syntax error (check quotes and escaping)

**404 Not Found**: Webhook was deleted or URL is wrong

**429 Rate Limited**: Too many requests (max 30/minute)

Use `--show-error` flag to see Discord's error response.

## Testing

Quick test to verify webhook works:

```bash
curl -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content":"Test from Claude"}'
```

If successful, message appears immediately in Discord.
