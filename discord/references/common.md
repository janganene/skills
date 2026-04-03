# Discord Common Concepts

## Authentication Methods

| Method | Used For | Format |
|---|---|---|
| Bot Token | REST API, discord.js, discord.py | `Authorization: Bot {TOKEN}` |
| Webhook URL | One-way message sending | Embedded in URL |
| OAuth2 | User login integration | Bearer Token |

## Environment Variable Setup (.env)

```
DISCORD_BOT_TOKEN=your_bot_token_here
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
DISCORD_CHANNEL_ID=123456789
DISCORD_APP_ID=987654321
```

## Gateway Intents

Intents must be explicitly declared to tell Discord which events your bot wants to receive.

| Intent | Purpose | Note |
|---|---|---|
| `Guilds` | Server info | Required for most bots |
| `GuildMessages` | Receive channel messages | |
| `MessageContent` | Read message content | Must be enabled in Developer Portal |
| `GuildMembers` | Member list access | Must be enabled in Developer Portal |
| `DirectMessages` | Receive DMs | |

## Rate Limit Rules

- Global: 50 requests per second
- Per channel: 5 messages per 5 seconds
- Rate limited response: HTTP 429 + `retry_after` field (in seconds)
- Stop sending immediately when `X-RateLimit-Remaining: 0` header is detected

## Permissions (Bitfield Values)

| Permission | Value |
|---|---|
| `SEND_MESSAGES` | `0x800` |
| `READ_MESSAGE_HISTORY` | `0x10000` |
| `EMBED_LINKS` | `0x4000` |
| `ADMINISTRATOR` | `0x8` |

## Embed Structure

```json
{
  "embeds": [{
    "title": "Title",
    "description": "Description",
    "color": 5814783,
    "fields": [
      { "name": "Field Name", "value": "Value", "inline": true }
    ],
    "footer": { "text": "Footer text" },
    "timestamp": "2026-04-03T00:00:00.000Z"
  }]
}
```