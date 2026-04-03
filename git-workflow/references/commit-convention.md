# Conventional Commits — Detailed Guide

## Full Format

```
<type>[(<scope>)][!]: <subject>

[body]

[footer(s)]
```

## Type Details

### feat — New Feature
```
feat(discord): add slash command support
feat!: drop support for Node 16        ← Breaking Change (use !)
```

### fix — Bug Fix
```
fix(webhook): retry on 429 rate limit response
fix: prevent crash when token is undefined
```

### docs — Documentation
```
docs: update installation guide in README
docs(api): add REST endpoint examples
```

### refactor — Refactoring
```
refactor(auth): extract token validation to separate module
```

### chore — Maintenance
```
chore: update .gitignore
chore(deps): bump discord.js from 14.15.0 to 14.16.0
```

### revert — Revert
```
revert: feat(discord): add slash command support

This reverts commit abc1234.
```

## Scope Guide

Use the name of the **module or component** being changed.

| Project Type | Scope Examples |
|---|---|
| Discord bot | `bot`, `commands`, `events`, `webhook` |
| Web app | `auth`, `api`, `ui`, `db` |
| Library | Module name |

## Breaking Changes

Two ways to mark a breaking change:

1. Using `!`: `feat!: remove deprecated login endpoint`
2. Using footer:
```
feat(api): change response format

BREAKING CHANGE: response body is now wrapped in a `data` key.
Migration: update all callers to use `res.data` instead of `res`.
```

## Writing the Body

- Explain **what** and **why**, not how (the code explains how)
- Wrap at 72 characters
- Separate from subject with a blank line

```
fix(discord): handle null response from webhook

The Discord webhook endpoint occasionally returns an empty body
during rate limit recovery. This caused an uncaught TypeError.

Added a null check before parsing the response body.
```

## Footer

```
Closes #42
Refs #87, #91
Co-authored-by: Jane <jane@example.com>
BREAKING CHANGE: ...
```

## Bad vs Good Examples

| Bad | Good |
|---|---|
| `fix bug` | `fix(auth): prevent token expiry crash` |
| `update` | `chore(deps): upgrade discord.js to v14.16` |
| `WIP` | `feat(commands): add /help slash command` |
| `Fixed the thing.` | `fix: handle empty webhook response` |