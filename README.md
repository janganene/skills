# Discord Skills for Antigravity / Agent Skills

A collection of 6 agent skills for Discord bot development and security.
Compatible with **Google Antigravity**, **Claude Code**, **Cursor**, **Codex CLI**,
**Gemini CLI**, and any agent that supports the open `SKILL.md` standard.

---

## Skills

| Skill | Description |
|---|---|
| `discord-js` | Build Discord bots with discord.js v14 (Node.js / TypeScript) |
| `discord-py-sdk` | Build Discord bots with discord.py v2.x (Python) |
| `discord-rest-api` | Call the Discord REST API directly with curl (no SDK) |
| `discord-webhook` | Create and post to Discord webhooks |
| `git-commit-convention` | Write standardized git commit messages (Conventional Commits) |
| `discord-markdown-safety` | Defend against Discord markdown vulnerabilities in bot code |

---

## Installation

### Google Antigravity — Global (all projects)

```bash
cp -R discord-js discord-py-sdk discord-rest-api discord-webhook \
      git-commit-convention discord-markdown-safety \
      ~/.gemini/antigravity/skills/
```

### Google Antigravity — Workspace (current project only)

```bash
mkdir -p .agents/skills
cp -R discord-js discord-py-sdk discord-rest-api discord-webhook \
      git-commit-convention discord-markdown-safety \
      .agents/skills/
```

### Claude Code — Global

```bash
cp -R discord-js discord-py-sdk discord-rest-api discord-webhook \
      git-commit-convention discord-markdown-safety \
      ~/.claude/skills/
```

### Claude Code — Project

```bash
mkdir -p .claude/skills
cp -R discord-js discord-py-sdk discord-rest-api discord-webhook \
      git-commit-convention discord-markdown-safety \
      .claude/skills/
```

### Universal (most agents — `.agent/skills/`)

```bash
mkdir -p .agent/skills
cp -R discord-js discord-py-sdk discord-rest-api discord-webhook \
      git-commit-convention discord-markdown-safety \
      .agent/skills/
```

---

## Usage

Once installed, trigger skills naturally in your agent chat:

- *"Build a Discord bot with slash commands in TypeScript"* → loads `discord-js`
- *"Write a Python bot that responds to on_message"* → loads `discord-py-sdk`
- *"Send a Discord embed with curl"* → loads `discord-rest-api`
- *"Post a deployment notification to a webhook"* → loads `discord-webhook`
- *"Write a commit message for this change"* → loads `git-commit-convention`
- *"Sanitize user input before sending to Discord"* → loads `discord-markdown-safety`

---

## License

MIT
