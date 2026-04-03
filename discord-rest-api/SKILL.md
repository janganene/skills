---
name: discord-rest-api
description: >
  Call the Discord Bot REST API directly via curl without any SDK.
  Use this skill when sending messages, managing channels, reading guild/member info,
  assigning roles, moderating members (timeout/kick/ban), sending DMs, adding reactions,
  or pinning messages through raw HTTP requests with no library dependency.
  Triggers: "send a Discord message", "create a channel", "ban a member",
  "call Discord API with curl", "Discord REST", "no SDK", "raw HTTP Discord".
compatibility:
  tools: curl, jq (optional)
---

# Discord REST API (curl)

Docs: https://discord.com/developers/docs/reference
Base URL: `https://discord.com/api/v10`
Auth header: `Authorization: Bot $DISCORD_BOT_TOKEN`

---

## Setup

### Create a bot

1. [Discord Developer Portal](https://discord.com/developers/applications) → New Application
2. Bot → Add Bot → Reset Token → copy token
3. Enable Privileged Gateway Intents if needed (Presence / Server Members / Message Content)
4. OAuth2 → URL Generator → scopes: `bot` `applications.commands` → invite to server

### Get IDs

User Settings → Advanced → Developer Mode → right-click any channel / user / server → Copy ID

```bash
export DISCORD_BOT_TOKEN="your-bot-token-here"
```

---

## Pipe safety rule

Always wrap curl in `bash -c '...'` when piping to jq — env vars are cleared in piped subshells.

```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq .
```

---

## Messages

### Send plain message

```bash
echo '{"content":"Hello from the bot!"}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Send embed

Common embed colors (decimal): Blue=5793266 Green=3066993 Red=15158332 Yellow=16776960

```bash
cat > /tmp/req.json << 'EOF'
{
  "embeds": [{
    "title": "Alert",
    "description": "Something happened.",
    "color": 5793266,
    "fields": [{"name": "Field", "value": "Value", "inline": true}],
    "footer": {"text": "Bot"},
    "timestamp": "2024-01-01T00:00:00.000Z"
  }]
}
EOF
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Send file

```bash
bash -c 'curl -s -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -F "payload_json={\"content\":\"Here is the file\"}" \
  -F "files[0]=@/path/to/file.png"'
```

### Get messages (last N)

```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID/messages?limit=10" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '.[] | {id, author: .author.username, content}'
```

### Edit a message

```bash
echo '{"content":"Updated content"}' > /tmp/req.json
bash -c 'curl -s -X PATCH \
  "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Delete a message

```bash
bash -c 'curl -s -X DELETE \
  "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

### Bulk delete (2–100 messages, must be < 14 days old)

```bash
echo '{"messages":["MESSAGE_ID_1","MESSAGE_ID_2"]}' > /tmp/req.json
bash -c 'curl -s -X POST \
  "https://discord.com/api/v10/channels/CHANNEL_ID/messages/bulk-delete" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Add reaction

Unicode emoji must be URL-encoded (👍 = `%F0%9F%91%8D`). Custom emoji: `name:id` URL-encoded.

```bash
bash -c 'curl -s -X PUT \
  "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID/reactions/%F0%9F%91%8D/@me" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Length: 0"'
```

### Pin / Unpin

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

Channel type values: 0=Text 2=Voice 4=Category 5=Announcement 13=Stage 15=Forum

```bash
# Get channel info
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, name, type, topic}'

# Create text channel
echo '{"name":"new-channel","type":0,"topic":"Channel topic"}' > /tmp/req.json
bash -c 'curl -s -X POST "https://discord.com/api/v10/guilds/GUILD_ID/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json' | jq '{id, name}'

# Edit channel
echo '{"name":"renamed","topic":"New topic"}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" -d @/tmp/req.json'

# Delete channel
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'

# Set slowmode (seconds, 0 to disable)
echo '{"rate_limit_per_user":10}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" -d @/tmp/req.json'
```

---

## Guilds & Members

```bash
# Guild info
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, name, member_count, owner_id}'

# List channels
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, name, type}'

# List members
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/members?limit=20" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {user: .user.username, nick}'

# Search members
bash -c 'curl -s \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/search?query=username&limit=5" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {user: .user.username, id: .user.id}'

# List roles
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/roles" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {id, name, color}'

# Add role
bash -c 'curl -s -X PUT \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID/roles/ROLE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" -H "Content-Length: 0"'

# Remove role
bash -c 'curl -s -X DELETE \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID/roles/ROLE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

---

## Moderation

Always include `X-Audit-Log-Reason` header for the audit trail.

```bash
# Timeout (communication_disabled_until = future ISO8601 timestamp)
echo '{"communication_disabled_until":"2025-01-01T00:05:00.000Z"}' > /tmp/req.json
bash -c 'curl -s -X PATCH \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "X-Audit-Log-Reason: Spamming" \
  -d @/tmp/req.json'

# Remove timeout
echo '{"communication_disabled_until":null}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" -d @/tmp/req.json'

# Kick
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "X-Audit-Log-Reason: Reason here"'

# Ban  (delete_message_seconds max 604800)
echo '{"delete_message_seconds":86400}' > /tmp/req.json
bash -c 'curl -s -X PUT "https://discord.com/api/v10/guilds/GUILD_ID/bans/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "X-Audit-Log-Reason: Reason here" \
  -d @/tmp/req.json'

# Unban
bash -c 'curl -s -X DELETE "https://discord.com/api/v10/guilds/GUILD_ID/bans/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'

# Ban list
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/bans" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '.[] | {user: .user.username, reason}'
```

---

## Users & DMs

```bash
# Bot info
bash -c 'curl -s "https://discord.com/api/v10/users/@me" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, username}'

# Get user by ID
bash -c 'curl -s "https://discord.com/api/v10/users/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq '{id, username}'

# Send DM  (two-step: create channel, then send)
echo '{"recipient_id":"USER_ID"}' > /tmp/req.json
DM_CHANNEL=$(bash -c 'curl -s -X POST "https://discord.com/api/v10/users/@me/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json' | jq -r '.id')

echo '{"content":"Hello!"}' > /tmp/req.json
bash -c "curl -s -X POST \
  \"https://discord.com/api/v10/channels/${DM_CHANNEL}/messages\" \
  -H \"Authorization: Bot \$DISCORD_BOT_TOKEN\" \
  -H \"Content-Type: application/json\" \
  -d @/tmp/req.json"
```

---

## Rate Limits

| Header | Meaning |
|---|---|
| `X-RateLimit-Limit` | Max requests in current window |
| `X-RateLimit-Remaining` | Requests remaining |
| `X-RateLimit-Reset` | Window reset (Unix timestamp) |
| `Retry-After` | Seconds to wait on HTTP 429 |

On HTTP 429 — read `Retry-After` and sleep before retrying. Never retry immediately.

```bash
bash -c 'curl -si "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | grep -i "x-ratelimit"
```

---

## Security Checklist

- Never expose or commit the bot token — store in environment variables only.
- Bot must have the correct permissions for each action (set during OAuth2 invite).
- Enable required Privileged Gateway Intents in Developer Portal before use.
- Always add `X-Audit-Log-Reason` on moderation actions.
