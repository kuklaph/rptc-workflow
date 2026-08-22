---
name: discord-notify
description: Send a Discord webhook notification only when the user explicitly requests a Discord notification and supplies or configures a webhook. Never invoke automatically from task duration, batch size, completion, or errors.
license: MIT
---

# Discord Notify

Discord messages are external side effects. Use this skill only after explicit
user intent to send a Discord notification.

## Configuration

Prefer an environment variable or a gitignored local settings file. Treat the
webhook URL as a secret. Never print it, commit it, or include it in logs.

## Procedure

1. Confirm the user requested a Discord message.
2. Resolve the webhook without displaying it.
3. Draft a concise message containing only information safe for that channel.
4. Send one request with `curl --silent --show-error --fail`.
5. Confirm success only when the command exits successfully.
6. On failure, report the error without exposing the webhook.

Do not send notifications merely because work was long-running, processed many
files, completed successfully, or encountered an error.
