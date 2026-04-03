# Discord Skills for Antigravity / Agent Skills
A collection of 5 agent skills for Discord bot development and Git workflow.
Compatible with **Google Antigravity**, **Claude Code**, **Cursor**, **Codex CLI**,
**Gemini CLI**, and any agent that supports the open `SKILL.md` standard.

---

## Skills

| Skill | Description |
|---|---|
| `discord` | Build Discord bots and integrations — covers discord.js (Node.js), discord.py (Python), REST API, and webhooks |
| `git-workflow` | Write standardized commit messages, name branches, and write pull requests (Conventional Commits) |
| `discord-markdown-safety` | Defend against Discord markdown vulnerabilities in bot code |

---

## Installation

### Google Antigravity — Global (all projects)
```bash
cp -R discord git-workflow discord-markdown-safety \
      ~/.gemini/antigravity/skills/
```

### Google Antigravity — Workspace (current project only)
```bash
mkdir -p .agents/skills
cp -R discord git-workflow discord-markdown-safety \
      .agents/skills/
```

### Claude Code — Global
```bash
cp -R discord git-workflow discord-markdown-safety \
      ~/.claude/skills/
```

### Claude Code — Project
```bash
mkdir -p .claude/skills
cp -R discord git-workflow discord-markdown-safety \
      .claude/skills/
```

### Universal (most agents — `.agent/skills/`)
```bash
mkdir -p .agent/skills
cp -R discord git-workflow discord-markdown-safety \
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
- *"Sanitize user input before sending to Discord"* → loads `discord-markdown-safety`

---

## License

MIT