---
name: discord
description: Use this skill when the user wants to build, integrate with, or send messages to Discord. Covers Discord bots using discord.js (Node.js) or discord.py (Python), direct REST API calls, and webhook integrations. Use when the user mentions Discord bots, slash commands, events, webhooks, embeds, channels, or sending messages to Discord.
---

# Discord Integration Skill

## Goal

A unified guide for building Discord bots and sending messages to Discord.
Select the appropriate section based on your language and integration method.

---

## 1. Choose Your Approach

| Situation | Recommended Approach |
|---|---|
| Node.js bot (events, slash commands) | discord.js |
| Python bot (events, slash commands) | discord.py |
| Send messages without a server | Webhook |
| Direct API control, language-agnostic | REST API |

Refer to the References below for your chosen approach.

---

## 2. Common Prerequisites

Read: `references/common.md`

- Always store bot tokens and webhook URLs in environment variables (`.env`)
- Never hardcode Bot Tokens or Webhook URLs in source code
- Intent configuration: Message Content Intent requires explicit activation in the Developer Portal
- Rate Limits: Global 50 req/s, per-channel 5 req/5s — always respect these limits

---

## 3. discord.js (Node.js)

Read: `references/discord-js.md`

**Install:**
```bash
npm install discord.js dotenv
```

**Key Patterns:**
- Specify required `GatewayIntentBits` when initializing `Client`
- Register slash commands using `REST` + `Routes.applicationCommands()`
- Event handlers: `client.on('interactionCreate', ...)`, `client.on('messageCreate', ...)`

**Run environment check:**
```bash
bash scripts/check_discord_js.sh
```

---

## 4. discord.py (Python)

Read: `references/discord-py.md`

**Install:**
```bash
pip install discord.py python-dotenv
```

**Key Patterns:**
- Use `commands.Bot` or `discord.Client`
- Slash commands: `@bot.tree.command()` decorator + `await bot.tree.sync()`
- Events: `@bot.event` + `async def on_message(message)`

**Run environment check:**
```bash
python scripts/check_discord_py.py
```

---

## 5. Discord Webhook

Read: `references/webhook.md`

**No installation required** — works with plain HTTP requests.

**Key Patterns:**
- Get Webhook URL: Channel Settings → Integrations → Webhooks → New Webhook
- `POST {WEBHOOK_URL}` with JSON body `{ "content": "..." }`
- Send embeds using the `embeds` array

```bash
# curl example
curl -X POST "$DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello from script!"}'
```

---

## 6. Discord REST API (Direct Calls)

Read: `references/rest-api.md`

**Base URL:** `https://discord.com/api/v10`

**Auth Header:**
```
Authorization: Bot {BOT_TOKEN}
Content-Type: application/json
```

**Key Endpoints:**
- Send message: `POST /channels/{channel_id}/messages`
- Get channel: `GET /channels/{channel_id}`
- Register slash command: `POST /applications/{app_id}/commands`

---

## Constraints

- Never hardcode tokens or webhook URLs in source code
- Do not use a Bot Token to replicate webhook functionality, or vice versa
- On Rate Limit (HTTP 429), wait for the `retry_after` value before retrying