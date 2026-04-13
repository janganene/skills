# Discord Skills for Antigravity / Agent Skills
A collection of agent skills for Discord bot development, Git workflow, and web security.
Compatible with **Google Antigravity**, **Claude Code**, **Cursor**, **Codex CLI**,
**Gemini CLI**, and any agent that supports the open `SKILL.md` standard.

---

## Skills

| Skill | Description |
|---|---|
| `discord` | Build Discord bots and integrations — covers discord.js (Node.js), discord.py (Python), REST API, and webhooks |
| `git-workflow` | Write standardized commit messages, name branches, and write pull requests (Conventional Commits) |
| `web-security` | Web application security audits — covers OWASP Top 10:2025, OWASP API Security, KISA/MOIS, and emerging threats (LLM injection, GraphQL, WebSocket) |

---

## Installation

### Recommended — npx (all skills, one command)

```bash
# Global (all projects)
npx skills add https://github.com/janganene/skills --skill web-security -g -y
```

```bash
# Project-local only
npx skills add https://github.com/janganene/skills --skill web-security -y
```

---

### Google Antigravity — Global (all projects)
```bash
cp -R discord git-workflow web-security \
      ~/.gemini/antigravity/skills/
```

### Google Antigravity — Workspace (current project only)
```bash
mkdir -p .agents/skills
cp -R discord git-workflow web-security \
      .agents/skills/
```

### Claude Code — Global
```bash
cp -R discord git-workflow web-security \
      ~/.claude/skills/
```

### Claude Code — Project
```bash
mkdir -p .claude/skills
cp -R discord git-workflow web-security \
      .claude/skills/
```

### Universal (most agents — `.agent/skills/`)
```bash
mkdir -p .agent/skills
cp -R discord git-workflow web-security \
      .agent/skills/
```

---

## Usage

Once installed, trigger skills naturally in your agent chat:

- *"Build a Discord bot with slash commands in TypeScript"* → loads `discord`
- *"Write a Python bot that responds to on_message"* → loads `discord`
- *"Send a Discord embed with curl"* → loads `discord`
- *"Post a deployment notification to a webhook"* → loads `discord`
- *"Write a commit message for this change"* → loads `git-workflow`
- *"Name this branch correctly"* → loads `git-workflow`
- *"Write a PR description for this change"* → loads `git-workflow`
- *"Run a security audit on this endpoint"* → loads `web-security`
- *"Check this code for OWASP vulnerabilities"* → loads `web-security`
- *"Is this API vulnerable to injection or SSRF?"* → loads `web-security`
- *"Scan for KISA/MOIS compliance issues"* → loads `web-security`

---

## License

MIT