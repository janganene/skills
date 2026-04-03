---
name: git-commit-convention
description: >
  Create standardized git commit messages following the Conventional Commits specification.
  Use this skill when writing or reviewing commit messages, choosing the right commit type,
  handling breaking changes, or coaching others on commit format.
  Triggers: "commit message", "git commit", "conventional commits", "commit type",
  "breaking change", "BREAKING CHANGE footer", "commit convention".
---

# Git Commit Convention

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Rules**
- Description: 50 characters or fewer, imperative mood (`add` not `added`), no trailing period
- Scope: optional, indicates area of change (`auth`, `api`, `ui`)
- Body: explain *why*, not *what* — wrap at 72 characters
- Footer: reference issues (`Closes #123`), flag breaking changes

---

## Commit Types

### Common

| Type | When to use |
|---|---|
| `feat` | New feature visible to the user |
| `fix` | Bug fix — incorrect behavior corrected |
| `docs` | Documentation only (README, comments, docstrings) |
| `style` | Formatting / whitespace only — no logic change |
| `refactor` | Code restructured without fixing bugs or adding features |
| `test` | Adding or updating tests — no production code change |
| `chore` | Tooling, packages, config — nothing user-facing |
| `perf` | Performance improvement without behavior change |
| `ci` | CI/CD pipeline, deployment scripts, GitHub Actions |
| `revert` | Reverting a previous commit |

### Occasionally Used

| Type | When to use |
|---|---|
| `build` | Build system or bundler changes (webpack → vite) |
| `deps` | Dependency updates (Dependabot, Renovate) |
| `security` | Security vulnerability fix, CVE patches, removing exposed secrets |
| `hotfix` | Critical production fix shipped outside the normal release cycle |
| `release` | Version bump, changelog generation, release tagging |
| `wip` | Work in progress checkpoint — always squash before merging |
| `init` | First commit of a new project or service |
| `config` | Runtime app configuration changes (not build config) |
| `merge` | Explicit merge commit when not using squash/fast-forward |
| `deprecate` | Marking a function, API, or module as deprecated |
| `remove` | Deleting dead code, unused files, or a dropped feature |
| `i18n` | Translations, locale files, internationalization strings |
| `a11y` | Accessibility — ARIA, keyboard nav, color contrast |
| `typo` | Spelling fix in code, strings, or comments |
| `env` | Adding, removing, or renaming environment variables |

---

## Breaking Changes

```
# Exclamation mark after type/scope
feat!: remove deprecated v1 endpoints

# Or BREAKING CHANGE footer
feat(api): change response shape for /users

BREAKING CHANGE: `data` field renamed to `users` in all list responses
```

---

## Examples

```
# Common
feat(auth): add Google OAuth login
fix(api): handle null response in user fetch
docs: update README with Docker setup steps
style: apply prettier formatting
refactor(store): extract cart logic into hook
test(checkout): add unit tests for discount calculation
chore(deps): upgrade axios to v1.6
perf(db): add index on orders.created_at
ci: add automated tests on pull request
revert: revert "feat: add dark mode toggle"

# Occasionally used
build: migrate bundler from webpack to vite
deps: bump lodash from 4.17.20 to 4.17.21
security: patch XSS in markdown renderer
hotfix(payment): fix crash on null card object in production
release: v2.4.0
wip: rough draft of notification system
init: bootstrap project with Next.js
deprecate: mark getUserById() as deprecated, use getUser()
remove: delete legacy stripe v1 integration
i18n: add Korean and Japanese locale files
a11y: add aria-label to icon-only nav buttons
typo: fix "recieve" -> "receive" in error messages
env: add REDIS_URL to .env.example
```

---

## Workflow

### 1. Check what changed

```bash
git diff --staged   # if files are staged
git diff            # if nothing staged yet
git status
```

### 2. Choose the right type

- New behavior the user sees? → `feat`
- Fixing broken behavior? → `fix`
- Critical, going straight to prod? → `hotfix`
- Moving code around without behavior change? → `refactor`
- Formatting only? → `style`
- Security issue? → `security`
- None of the above? → `chore`

### 3. Commit

```bash
# Single line
git commit -m "feat(auth): add magic link login"

# With body
git commit -m "fix(api): handle empty pagination response

Previously the app crashed when the API returned an empty
data array. Added a null check before mapping results.

Closes #412"
```

---

## Best Practices

- One logical change per commit
- Reference issues in footer: `Closes #123` `Refs #456`
- Never commit secrets (.env, credentials, private keys)
- Squash `wip` commits before merging
- Use `!` or `BREAKING CHANGE:` footer for breaking changes
