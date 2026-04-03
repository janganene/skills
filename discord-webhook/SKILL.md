---
name: discord-webhook
description: >
  Create, manage, and post messages to Discord webhooks.
  Use this skill when posting to a Discord channel via webhook URL (no bot token needed),
  creating or deleting webhooks, listing webhooks in a channel, sending embeds or files
  via webhook, or editing/deleting webhook messages after sending.
  Triggers: "post to Discord webhook", "send webhook message", "create Discord webhook",
  "webhook embed", "Discord webhook URL", "incoming webhook", "webhook notify".
compatibility:
  tools: curl
---

# Discord Webhooks

Docs: https://discord.com/developers/docs/resources/webhook
Base URL: `https://discord.com/api/v10`

Webhooks allow sending messages to a Discord channel without a full bot session.

---

## Webhook via Bot Token (managed)

Required for creating, listing, editing, and deleting webhooks.

```bash
export DISCORD_BOT_TOKEN="your-bot-token-here"
```

### Create webhook in a channel

```bash
echo '{"name":"My Webhook","avatar":null}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/webhooks" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json' | jq '{id, name, token, url}'
```

Save the returned `id` and `token`. The URL is `https://discord.com/api/webhooks/{id}/{token}`.

### List webhooks in a channel

```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID/webhooks" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, name, token}'
```

### List all webhooks in a guild

```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/webhooks" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, name, channel_id}'
```

### Edit a webhook

```bash
echo '{"name":"New Name","channel_id":"NEW_CHANNEL_ID"}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/webhooks/WEBHOOK_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Delete a webhook

```bash
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/webhooks/WEBHOOK_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

---

## Post via Webhook URL (no bot token required)

### Send plain message

```bash
echo '{"content":"Message via webhook","username":"Custom Name"}' > /tmp/req.json
curl -s -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json
```

Optional parameters: `username` (override display name) · `avatar_url` · `tts`

### Send embed

Up to 10 embeds per message.

```bash
cat > /tmp/req.json << 'EOF'
{
  "username": "Notifier",
  "avatar_url": "https://example.com/avatar.png",
  "embeds": [{
    "title": "Deployment Complete",
    "description": "Build **v1.2.3** deployed successfully.",
    "color": 3066993,
    "fields": [
      {"name": "Environment", "value": "Production", "inline": true},
      {"name": "Duration",    "value": "1m 32s",     "inline": true}
    ],
    "footer": {"text": "CI/CD Bot"},
    "timestamp": "2024-01-01T12:00:00.000Z"
  }]
}
EOF
curl -s -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json
```

### Send file

```bash
curl -s -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -F 'payload_json={"content":"Report attached"}' \
  -F "files[0]=@/path/to/report.pdf"
```

### Send with wait=true (get message ID back for later edits)

```bash
echo '{"content":"Tracked message"}' > /tmp/req.json
curl -s -X POST \
  "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN?wait=true" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json | jq '{id, channel_id}'
```

---

## Edit & Delete Sent Messages

Uses the webhook token — not the bot token.

```bash
# Edit
echo '{"content":"Updated content","embeds":[]}' > /tmp/req.json
curl -s -X PATCH \
  "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN/messages/MESSAGE_ID" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json

# Delete
curl -s -X DELETE \
  "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN/messages/MESSAGE_ID"
```

---

## Forum Channel Webhooks

```bash
# Create a new forum thread
cat > /tmp/req.json << 'EOF'
{"content": "New topic post", "thread_name": "My New Thread"}
EOF
curl -s -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json

# Post into an existing thread
echo '{"content":"Reply in thread"}' > /tmp/req.json
curl -s -X POST \
  "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN?thread_id=THREAD_ID" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json
```

---

## Webhook Types Reference

| Type | Value | Description |
|---|---|---|
| `Incoming` | 1 | Standard channel-posting webhook |
| `ChannelFollower` | 2 | Following an Announcement channel |
| `Application` | 3 | Used by Interactions / slash commands |

---

## Rate Limits

Each webhook has its own per-route bucket. On HTTP 429 — respect `Retry-After`.

```bash
curl -si -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content":"test"}' | grep -i "x-ratelimit"
```

---

## Security Notes

- Webhook tokens are sensitive — anyone with the URL can post to the channel.
- Rotate or delete compromised webhooks immediately via the bot token endpoint.
- Use `?wait=true` when you need to track and later edit messages.
- Never log or commit webhook URLs to public repositories.
