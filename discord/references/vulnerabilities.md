# Discord Markdown — Vulnerability Reference

CVE records, incidents, and attack patterns for `discord-markdown-safety`.

---

## 1. Mention Injection

**Real-world incident**: cscareers.dev (45,000+ members) — Feb 2022.
A user passed `@everyone` as a command argument. The bot echoed it in an error message
with admin-level permissions, triggering a mass ping.
**Reference**: https://www.cscareers.dev/blog/the-importance-of-sanitization-in-a-discord-bot

**Fix layers**:
1. Insert `\u200b` after `@` (string layer)
2. `allowed_mentions: { parse: [] }` (API layer — authoritative)

---

## 2. discord-markdown npm XSS / RCE

**Package**: `discord-markdown` on npm
**Affected**: < v2.3.1
**CVE**: SNYK-JS-DISCORDMARKDOWN-552161
**Issue**: `<`, `>`, `&` not sanitized inside code blocks → XSS / RCE in web renderers.
**References**:
- https://snyk.io/vuln/SNYK-JS-DISCORDMARKDOWN-552161
- https://github.com/brussell98/discord-markdown/issues/13

---

## 3. Masked Link Spoofing

**Reference**: https://gist.github.com/Nickguitar/7c6bdfa8255b2ec7e0d6d4015550ce4c

Discord prevents raw URLs in display text but allows social engineering via lookalike text.
Bots forwarding user-composed `[text](url)` amplify the attack surface.

---

## 4. escape_markdown Edge Cases (discord.py)

- **Blockquote `>`**: regex missing `re.MULTILINE` — only escapes `>` at absolute string start.
  Issue: https://github.com/Rapptz/discord.py/issues/5897
- **Masked links `[`**: brackets not escaped.
  Issue: https://github.com/Rapptz/discord.py/issues/4206

---

## 5. URL Unfurling Exfiltration (LLM Bots)

Discord and Slack fetch URLs to generate link previews (unfurling).
Prompt injection can cause LLM bots to embed private data in a URL, which is then
exfiltrated when Discord fetches the preview.

**Timeline**:
| Date | Target | Notes |
|---|---|---|
| Oct 2024 | Various AI apps | Unfurling exfiltration via LLM markdown documented |
| Dec 2024 | Anthropic Claude iOS | Image URL markdown exploited (patched) |
| Jan 2025 | Microsoft 365 Copilot | CVE-2025-32711 "EchoLeak" — zero-click exfiltration |

**Reference**: https://simonwillison.net/tags/exfiltration-attacks/

---

## Markdown Special Character Reference

| Character | Discord Effect | Escape |
|---|---|---|
| `*` | Italic / bold | `\*` |
| `_` | Italic / underline | `\_` |
| `~` | Strikethrough | `\~` |
| `` ` `` | Code | `` \` `` |
| `\|` | Spoiler | `\|` |
| `>` | Blockquote (line start) | `\>` |
| `[` | Masked link | `\[` |
| `\` | Escape char | `\\` |
| `#` | Header (line start) | `\#` |
| `-` | Bullet (line start) | `\-` |

Universal escape regex: `/([\\*_~|`>\[\]])/g` → `\$1`
