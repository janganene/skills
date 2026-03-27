---
name: discord-api
description: Interact with the Discord Bot API via curl. Send messages, manage channels, read guild info, handle webhooks, and moderate content using a bot token.
---

# Discord Bot API

Call the Discord REST API directly with `curl` — no SDK required.

> Official docs: https://discord.com/developers/docs/reference

---

## Setup

### 1. Create a Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications) → New Application
2. Bot section → Add Bot → Reset Token → copy token
3. Enable intents if needed: Presence / Server Members / Message Content
4. OAuth2 → URL Generator → scopes: `bot`, `applications.commands` → invite to server

### 2. Get IDs

Enable Developer Mode: User Settings → Advanced → Developer Mode  
Right-click any channel / user / server → Copy ID

### 3. Set Token

```bash
export DISCORD_BOT_TOKEN="your-bot-token-here"
```

---

## Base URL & Auth

```
Base URL:  https://discord.com/api/v10
Auth:      Authorization: Bot $DISCORD_BOT_TOKEN
```

> **Pipe safety:** Always wrap curl in `bash -c '...'` when piping to jq — environment variables are cleared in piped subshells.
> ```bash
> bash -c 'curl -s "https://discord.com/api/v10/..." -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq .
> ```

---

## Messages

### Send a message
```bash
echo '{"content":"Hello from the bot!"}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Send an embed
```bash
cat > /tmp/req.json << 'EOF'
{
  "embeds": [{
    "title": "Alert",
    "description": "Something happened.",
    "color": 5793266,
    "footer": { "text": "Bot" }
  }]
}
EOF
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Send a file
```bash
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -F "payload_json={\"content\":\"Here is the file\"}" \
  -F "files[0]=@/path/to/file.png"'
```

### Get messages (last 10)
```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID/messages?limit=10" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, author: .author.username, content}'
```

### Get a specific message
```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, content, author: .author.username}'
```

### Edit a message
```bash
echo '{"content":"Updated content"}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Delete a message
```bash
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

### Bulk delete messages (2–100)
```bash
echo '{"messages":["MESSAGE_ID_1","MESSAGE_ID_2"]}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages/bulk-delete" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Add a reaction
```bash
# Emoji must be URL-encoded: 👍 = %F0%9F%91%8D
bash -c 'curl -s -X PUT "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID/reactions/%F0%9F%91%8D/@me" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Length: 0"'
```

### Pin / unpin a message
```bash
# Pin
bash -c 'curl -s -X PUT "https://discord.com/api/v10/channels/CHANNEL_ID/pins/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" -H "Content-Length: 0"'

# Unpin
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/channels/CHANNEL_ID/pins/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

---

## Channels

### Get channel info
```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, name, type, guild_id, topic}'
```

### Create a text channel
```bash
echo '{"name":"new-channel","type":0,"topic":"Channel topic"}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/guilds/GUILD_ID/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json' | jq '{id, name}'
```

### Edit a channel
```bash
echo '{"name":"renamed-channel","topic":"New topic"}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Delete a channel
```bash
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

### Set slowmode
```bash
echo '{"rate_limit_per_user":10}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Channel types

| Type | Description |
|------|-------------|
| 0 | Text |
| 2 | Voice |
| 4 | Category |
| 5 | Announcement |
| 13 | Stage |
| 15 | Forum |

---

## Guilds & Members

### Get guild info
```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, name, member_count, owner_id}'
```

### List guild channels
```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, name, type}'
```

### Get guild members
```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/members?limit=20" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {user: .user.username, nick, joined_at}'
```

### Search members by name
```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/members/search?query=username&limit=5" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {user: .user.username, id: .user.id}'
```

### Get guild roles
```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/roles" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, name, color, position}'
```

### Add role to member
```bash
bash -c 'curl -s -X PUT "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID/roles/ROLE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" -H "Content-Length: 0"'
```

### Remove role from member
```bash
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID/roles/ROLE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

---

## Moderation

### Timeout a member
```bash
# duration in ISO8601 — e.g. 5 minutes from now
echo '{"communication_disabled_until":"2025-01-01T00:05:00.000Z"}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Remove timeout
```bash
echo '{"communication_disabled_until":null}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Kick a member
```bash
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "X-Audit-Log-Reason: Reason here"'
```

### Ban a member
```bash
echo '{"delete_message_seconds":86400}' > /tmp/req.json
bash -c 'curl -s -X PUT "https://discord.com/api/v10/guilds/GUILD_ID/bans/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "X-Audit-Log-Reason: Reason here" \
  -d @/tmp/req.json'
```

### Unban a member
```bash
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/guilds/GUILD_ID/bans/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

### Get ban list
```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/bans" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {user: .user.username, reason}'
```

---

## Webhooks

### Create a webhook
```bash
echo '{"name":"My Webhook"}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/webhooks" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json' | jq '{id, name, token}'
```

### List channel webhooks
```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID/webhooks" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, name, token}'
```

### Post via webhook (no bot token needed)
```bash
echo '{"content":"Message via webhook","username":"Custom Name"}' > /tmp/req.json
curl -s -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json
```

### Delete a webhook
```bash
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/webhooks/WEBHOOK_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

---

## Users

### Get bot info
```bash
bash -c 'curl -s "https://discord.com/api/v10/users/@me" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, username, discriminator}'
```

### Get a user
```bash
bash -c 'curl -s "https://discord.com/api/v10/users/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, username, discriminator}'
```

### Send a DM
```bash
# 1. Create DM channel
echo '{"recipient_id":"USER_ID"}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/users/@me/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json' | jq '{id}'

# 2. Send message to returned channel id
echo '{"content":"Hello!"}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/DM_CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

---

## Rate Limits

Check response headers after every request:

| Header | Meaning |
|--------|---------|
| `X-RateLimit-Limit` | Max requests in window |
| `X-RateLimit-Remaining` | Requests left |
| `X-RateLimit-Reset` | Window reset time (Unix) |
| `Retry-After` | Seconds to wait when 429 |

```bash
# Show rate limit headers
bash -c 'curl -si "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | grep -i "x-ratelimit"
```

---

## Guidelines

- Never expose or commit the bot token
- Bot needs correct permissions for each action (set during invite)
- Enable required Gateway Intents in the Developer Portal
- Handle `429 Too Many Requests` with backoff using `Retry-After`
- Use `X-Audit-Log-Reason` header for moderation actions
