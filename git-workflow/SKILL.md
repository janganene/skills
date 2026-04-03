---
name: git-workflow
description: Use this skill when the user wants to write a git commit message, create a PR (pull request), design a branch naming strategy, write a PR description, or follow Git workflow conventions. Use when the user mentions commit, PR, branch, merge, rebase, or git conventions.
---

# Git Workflow Skill

## Goal

Enforce consistent conventions for commit messages, branch naming, and pull request descriptions.

---

## 1. Commit Messages (Conventional Commits)

Read: `references/commit-convention.md`

**Format:**
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Core Rules:**
- `type` must be chosen from the list below
- `subject` is imperative mood, lowercase, no trailing period
- One commit = one logical change

**Type List:**

| type | When to use |
|---|---|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation changes only |
| `style` | Formatting, no logic change |
| `refactor` | Code restructure, no behavior change |
| `test` | Adding or updating tests |
| `chore` | Build, dependencies, config changes |
| `perf` | Performance improvement |
| `ci` | CI/CD configuration changes |
| `revert` | Reverting a previous commit |

**Examples:**
```
feat(auth): add OAuth2 login with Google
fix(api): handle null response from Discord webhook
docs(readme): add skill installation guide
chore(deps): upgrade discord.js to v14.16
```

**Validate a commit message with the script:**
```bash
bash scripts/validate_commit.sh "feat(auth): add login"
```

---

## 2. Branch Strategy

Read: `references/branching-strategy.md`

**Branch Naming Convention:**
```
<type>/<issue-number>-<short-description>
```

**Examples:**
```
feat/42-oauth-login
fix/87-webhook-null-error
docs/12-update-readme
refactor/55-auth-module
```

**Branch Structure (GitHub Flow):**
```
main          ← always deployable
  └─ feat/...   ← feature development
  └─ fix/...    ← bug fixes
  └─ docs/...   ← documentation
```

> For complex projects, consider adding a `develop` branch (Git Flow).
> Read: `references/branching-strategy.md` → "Git Flow" section

**Validate a branch name with the script:**
```bash
bash scripts/validate_branch.sh "feat/42-oauth-login"
```

---

## 3. Pull Requests

Read: `references/pr-template.md`

Use the template at `resources/PR_TEMPLATE.md` when writing a PR.

**Key Sections:**
1. **What** — What was changed
2. **Why** — Why the change was needed
3. **How to Test** — How to verify the change
4. **Screenshots** — Attach if there are UI changes

**PR Checklist:**
- [ ] Branch name follows the convention
- [ ] Commit messages follow Conventional Commits
- [ ] Tests were added or updated
- [ ] Documentation was updated

---

## Constraints

- Keep the `subject` line of a commit message under 72 characters
- Never commit directly to `main`
- Do not mix multiple features or fixes in a single PR
- Squash or clean up `WIP:` commits before merging