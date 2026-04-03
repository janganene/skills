---
name: discord-markdown-safety
description: >
  Defend against Discord markdown vulnerabilities in bot code.
  Use this skill when handling user input in Discord bots, preventing mention injection
  (@everyone/@here abuse), escaping markdown formatting, sanitizing user-supplied text
  before sending to Discord, fixing discord-markdown npm XSS, blocking masked link spoofing,
  or securing LLM bots against URL unfurling exfiltration.
  Covers Python (discord.py), TypeScript, JavaScript, and language-agnostic patterns.
  Do not use for questions that are purely about Discord UI — this skill is for bot security code.
  Triggers: "mention injection", "@everyone abuse", "escape markdown", "sanitize Discord input",
  "discord-markdown XSS", "masked link spoofing", "allowedMentions", "Discord bot security".
---

# Discord Markdown Safety

Security skill for defending against Discord markdown vulnerabilities.
Applies to **Python (discord.py)**, **TypeScript / JavaScript (discord.js)**, and any
language communicating with the Discord API.

---

## Vulnerability Overview

| # | Vulnerability | Severity | Affects |
|---|---|---|---|
| 1 | Mention Injection (`@everyone`, `@here`, snowflake pings) | HIGH | All bots that echo user input |
| 2 | `discord-markdown` npm XSS / RCE (< v2.3.1) | HIGH | Web renderers using the npm package |
| 3 | Masked Link URL Spoofing `[text](url)` | MEDIUM | Bots that forward user links |
| 4 | `escape_markdown` edge cases (`>` blockquote, `[` brackets) | MEDIUM | discord.py bots |
| 5 | URL Unfurling Data Exfiltration (LLM bots) | HIGH | Bots with access to private data |

For CVE references and incident reports, see [`references/vulnerabilities.md`](references/vulnerabilities.md).

---

## Step 1 — Identify the Context

Before generating any code, determine:
1. **Language/framework**: Python · JavaScript · TypeScript · other?
2. **What is being echoed?**: Username, command arg, error message, LLM output?
3. **Bot permission level**: Does the bot have `Mention Everyone`?

---

## Step 2 — Apply the Right Defense

### Vuln 1 — Mention Injection

**Attack**: User passes `@everyone` as input → bot echoes it with elevated permissions → mass ping.

**Defense**: neutralize the string AND lock down `allowed_mentions` at send time.

**Python (discord.py)**:
```python
import re, discord

def sanitize_mentions(text: str) -> str:
    text = re.sub(r'@(everyone|here)', r'@\u200b\1', text)
    text = re.sub(r'<@[!&]?\d+>', lambda m: m.group().replace('@', '@\u200b'), text)
    return text

SAFE_MENTIONS = discord.AllowedMentions(everyone=False, roles=False, users=False)

await channel.send(sanitize_mentions(user_input), allowed_mentions=SAFE_MENTIONS)
```

**TypeScript (discord.js)**:
```typescript
function sanitizeMentions(text: string): string {
  return text
    .replace(/@(everyone|here)/g, '@\u200b$1')
    .replace(/<@[!&]?\d+>/g, (m) => m.replace('@', '@\u200b'));
}

await channel.send({
  content: sanitizeMentions(userInput),
  allowedMentions: { parse: [] },   // parse:[] blocks all auto-resolved mentions
});
```

**JavaScript (discord.js, CommonJS)**:
```javascript
function sanitizeMentions(text) {
  return text
    .replace(/@(everyone|here)/g, '@\u200b$1')
    .replace(/<@[!&]?\d+>/g, (m) => m.replace('@', '@\u200b'));
}

await channel.send({ content: sanitizeMentions(userInput), allowedMentions: { parse: [] } });
```

**Discord REST API (any language)**:
```json
{ "content": "your message", "allowed_mentions": { "parse": [] } }
```

---

### Vuln 2 — Markdown Formatting Injection

**Attack**: Username `__admin__` or `*important*` causes unintended formatting in bot messages.
Common in Python bots when `__init__` appears in error echoes.

**Characters to escape**: `\ * _ ~ | > ` [ ]`

**Python (discord.py)** — extends built-in with two missing cases:
```python
import re, discord

def escape_markdown_safe(text: str) -> str:
    text = discord.utils.escape_markdown(text)
    text = re.sub(r'^>', r'\>', text, flags=re.MULTILINE)  # fix blockquote (MULTILINE bug)
    text = text.replace('[', '\\[')                         # fix masked link bracket
    return text
```

**TypeScript / JavaScript (discord.js)**:
```typescript
import { escapeMarkdown } from 'discord.js';

function escapeMarkdownSafe(text: string): string {
  let s = escapeMarkdown(text);
  s = s.replace(/^>/gm, '\\>');   // fix blockquote at line start
  s = s.replace(/\[/g, '\\[');    // fix masked link brackets
  return s;
}
```

**Any language — universal regex**:
```
Pattern:   /([\\*_~|`>\[\]])/g
Replace:   \$1
```

---

### Vuln 3 — Masked Link Spoofing

**Attack**: `[Click here — trusted site](https://phishing.example.com)` hides the real destination.

**Python**:
```python
import re

def strip_masked_links(text: str) -> str:
    return re.sub(r'\[([^\]]+)\]\((https?://[^\)]+)\)', r'\2', text)

def is_display_spoofing_url(display: str) -> bool:
    return bool(re.search(r'https?://', display))
```

**TypeScript / JavaScript**:
```typescript
const stripMaskedLinks = (t: string) =>
  t.replace(/\[([^\]]+)\]\((https?:\/\/[^)]+)\)/g, '$2');

const isDisplaySpoofingUrl = (display: string) => /https?:\/\//.test(display);
```

---

### Vuln 4 — discord-markdown npm XSS / RCE

**CVE**: SNYK-JS-DISCORDMARKDOWN-552161 — improper HTML sanitization in code blocks.

**Fix**:
```bash
npm install discord-markdown@latest   # ensure >= 2.3.1
```

**If upgrade is blocked** — pre-escape before the parser:
```javascript
function preEscape(text) {
  return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
const safeHtml = require('discord-markdown').toHTML(preEscape(userText));
```

---

### Vuln 5 — URL Unfurling Exfiltration (LLM Bots)

**Attack**: Prompt injection causes an LLM bot to construct a link where the URL encodes
private data. Discord's link preview fetch sends that data to the attacker's server.
Actively reported in 2024–2025 against Slack, Discord, and mobile AI apps.

**Python**:
```python
from urllib.parse import urlparse

ALLOWED_DOMAINS = {"your-domain.com", "docs.your-domain.com"}

def is_safe_url(url: str) -> bool:
    try:
        return urlparse(url).netloc in ALLOWED_DOMAINS
    except Exception:
        return False

def sanitize_llm_links(text: str) -> str:
    def replace(m):
        display, url = m.group(1), m.group(2)
        return m.group(0) if is_safe_url(url) else display
    return re.sub(r'\[([^\]]+)\]\((https?://[^\)]+)\)', replace, text)
```

**TypeScript**:
```typescript
const ALLOWED = new Set(['your-domain.com', 'docs.your-domain.com']);

const isSafeUrl = (url: string) => {
  try { return ALLOWED.has(new URL(url).hostname); } catch { return false; }
};

const sanitizeLlmLinks = (text: string) =>
  text.replace(/\[([^\]]+)\]\((https?:\/\/[^)]+)\)/g,
    (_, display, url) => (isSafeUrl(url) ? `[${display}](${url})` : display));
```

**Suppress Discord unfurl** — wrap URL in `<>`:
```python
safe_display = f"<{url}>"   # Discord does not unfurl <url> wrapped links
```

---

## Step 3 — Verify Bot Permissions

- [ ] Bot role does **not** have `Mention Everyone` unless required.
- [ ] All `send()` / `reply()` calls include `allowed_mentions` at minimum necessary scope.
- [ ] Webhook payloads include `"allowed_mentions": {"parse": []}`.

---

## Guidelines

- **Defense in depth**: use both string sanitization AND `allowed_mentions` — either alone can fail.
- **Escape at output time**: escape immediately before the string enters a Discord message.
- **Never trust display names**: always escape usernames and nicknames.
- **Audit elevated bots**: any bot with `Mention Everyone` or `Administrator` is highest risk.
- **Treat LLM output as untrusted**: validate all links in LLM-generated content before sending.
