---
name: discord-rest-api
description: >
  Call the Discord Bot REST API directly via curl without any SDK.
  Use this skill when sending messages, managing channels, reading guild/member info,
  assigning roles, moderating members (timeout/kick/ban), sending DMs, adding reactions,
  or pinning messages through raw HTTP requests.
  Triggers: "send a Discord message", "create a channel", "ban a member",
  "call Discord API with curl", "Discord REST", "no SDK".
---

# Discord REST API (curl)

Official docs: https://discord.com/developers/docs/reference  
Base URL: `https://discord.com/api/v10`  
Auth header: `Authorization: Bot $DISCORD_BOT_TOKEN`

---

## Setup

### Create a bot

1. [Discord Developer Portal](https://discord.com/developers/applications) -> New Application
2. Bot -> Add Bot -> Reset Token -> copy token
3. Enable Privileged Gateway Intents if needed: Presence / Server Members / Message Content
4. OAuth2 -> URL Generator -> scopes: `bot`, `applications.commands` -> invite to server

### Get IDs

Enable Developer Mode: User Settings -> Advanced -> Developer Mode  
Right-click any channel / user / server -> Copy ID

### Set environment variable

```bash
export DISCORD_BOT_TOKEN="your-bot-token-here"
```

---

## Pipe safety rule

Always wrap curl in `bash -c '...'` when piping to jq.
Environment variables are cleared in piped subshells.

```bash
# Correct
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | jq .
```

---

## Messages

### Send a plain message

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
    "fields": [
      {"name": "Field", "value": "Value", "inline": true}
    ],
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

Common embed colors (decimal): Blue = 5793266, Green = 3066993, Red = 15158332, Yellow = 16776960

### Send a file

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

### Bulk delete messages (2-100, must be under 14 days old)

```bash
echo '{"messages":["MESSAGE_ID_1","MESSAGE_ID_2"]}' > /tmp/req.json
bash -c 'curl -s -X POST \
  "https://discord.com/api/v10/channels/CHANNEL_ID/messages/bulk-delete" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Add a reaction

Emoji must be URL-encoded. Unicode example: thumbsup (👍) = `%F0%9F%91%8D`  
Custom emoji format: `name:id` URL-encoded.

```bash
bash -c 'curl -s -X PUT \
  "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID/reactions/%F0%9F%91%8D/@me" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Length: 0"'
```

### Pin / Unpin a message

```bash
# Pin
bash -c 'curl -s -X PUT \
  "https://discord.com/api/v10/channels/CHANNEL_ID/pins/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Length: 0"'

# Unpin
bash -c 'curl -s -X DELETE \
  "https://discord.com/api/v10/channels/CHANNEL_ID/pins/MESSAGE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

---

## Channels

Channel type values: 0 = Text, 2 = Voice, 4 = Category, 5 = Announcement, 13 = Stage, 15 = Forum

### Get channel info

```bash
bash -c 'curl -s "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '{id, name, type, guild_id, topic}'
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

### Set slowmode (seconds, 0 to disable)

```bash
echo '{"rate_limit_per_user":10}' > /tmp/req.json
bash -c 'curl -s -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

---

## Guilds and Members

### Get guild info

```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '{id, name, member_count, owner_id}'
```

### List guild channels

```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '.[] | {id, name, type}'
```

### Get guild members

```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/members?limit=20" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '.[] | {user: .user.username, nick, joined_at}'
```

### Search members by username

```bash
bash -c 'curl -s \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/search?query=username&limit=5" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '.[] | {user: .user.username, id: .user.id}'
```

### Get guild roles

```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/roles" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '.[] | {id, name, color, position}'
```

### Add / Remove role

```bash
# Add
bash -c 'curl -s -X PUT \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID/roles/ROLE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" -H "Content-Length: 0"'

# Remove
bash -c 'curl -s -X DELETE \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID/roles/ROLE_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

---

## Moderation

Always include `X-Audit-Log-Reason` header for audit trail.

### Timeout a member

`communication_disabled_until` must be a future ISO8601 timestamp. Set to `null` to remove.

```bash
# Apply timeout
echo '{"communication_disabled_until":"2025-01-01T00:05:00.000Z"}' > /tmp/req.json
bash -c 'curl -s -X PATCH \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "X-Audit-Log-Reason: Spamming" \
  -d @/tmp/req.json'

# Remove timeout
echo '{"communication_disabled_until":null}' > /tmp/req.json
bash -c 'curl -s -X PATCH \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json'
```

### Kick a member

```bash
bash -c 'curl -s -X DELETE \
  "https://discord.com/api/v10/guilds/GUILD_ID/members/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "X-Audit-Log-Reason: Reason here"'
```

### Ban a member

`delete_message_seconds`: message history seconds to purge (max 604800 = 7 days).

```bash
echo '{"delete_message_seconds":86400}' > /tmp/req.json
bash -c 'curl -s -X PUT \
  "https://discord.com/api/v10/guilds/GUILD_ID/bans/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "X-Audit-Log-Reason: Reason here" \
  -d @/tmp/req.json'
```

### Unban a member

```bash
bash -c 'curl -s -X DELETE \
  "https://discord.com/api/v10/guilds/GUILD_ID/bans/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"'
```

### Get ban list

```bash
bash -c 'curl -s "https://discord.com/api/v10/guilds/GUILD_ID/bans" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '.[] | {user: .user.username, reason}'
```

---

## Users

### Get bot info

```bash
bash -c 'curl -s "https://discord.com/api/v10/users/@me" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '{id, username, discriminator}'
```

### Get a user by ID

```bash
bash -c 'curl -s "https://discord.com/api/v10/users/USER_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' \
  | jq '{id, username, discriminator}'
```

### Send a DM

```bash
# Step 1: Create DM channel, capture ID
echo '{"recipient_id":"USER_ID"}' > /tmp/req.json
DM_CHANNEL=$(bash -c 'curl -s -X POST "https://discord.com/api/v10/users/@me/channels" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d @/tmp/req.json' | jq -r '.id')

# Step 2: Send message to DM channel
echo '{"content":"Hello!"}' > /tmp/req.json
bash -c "curl -s -X POST \
  \"https://discord.com/api/v10/channels/${DM_CHANNEL}/messages\" \
  -H \"Authorization: Bot \$DISCORD_BOT_TOKEN\" \
  -H \"Content-Type: application/json\" \
  -d @/tmp/req.json"
```

---

## Rate Limits

| Header                  | Meaning                            |
|-------------------------|------------------------------------|
| `X-RateLimit-Limit`     | Max requests in current window     |
| `X-RateLimit-Remaining` | Requests remaining                 |
| `X-RateLimit-Reset`     | Window reset time (Unix timestamp) |
| `Retry-After`           | Seconds to wait on HTTP 429        |

```bash
bash -c 'curl -si "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN"' | grep -i "x-ratelimit"
```

On HTTP 429, read `Retry-After` and sleep before retrying. Never retry immediately.

---

## Security checklist

- Never expose or commit the bot token. Store in environment variables only.
- Bot must have the correct permissions for each action (configure during OAuth2 invite).
- Enable required Privileged Gateway Intents in the Developer Portal before use.
- Always add `X-Audit-Log-Reason` on moderation actions for accountability.
