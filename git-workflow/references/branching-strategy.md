# Branch Strategy Guide

## Branch Naming Convention

```
<type>/<issue-number>-<short-description>
```

- `type`: same as commit types (`feat`, `fix`, `docs`, `refactor`, `chore`, etc.)
- `issue-number`: GitHub/Jira issue number (optional if none exists)
- `short-description`: 2–4 words, hyphen-separated, lowercase

**Examples:**
```
feat/42-oauth-google-login
fix/87-discord-webhook-null
docs/update-readme
refactor/55-auth-module-split
chore/upgrade-discordjs
```

---

## GitHub Flow (Small Teams, Single Deployment Target)

```
main
├── feat/42-oauth-login        (PR → main)
├── fix/87-webhook-error       (PR → main)
└── docs/readme-update         (PR → main)
```

**Rules:**
- `main` is always deployable
- Keep branches short-lived (1–3 days)
- Delete branches immediately after merging

**Best for:** Small teams, SaaS products, continuous deployment

---

## Git Flow (Complex Release Cycles)

```
main          ← release tags only
develop       ← integration branch
├── feat/42-oauth-login     (PR → develop)
├── fix/87-webhook-error    (PR → develop)
release/1.2.0               (develop → release → main)
hotfix/critical-bug         (main → hotfix → main + develop)
```

**Rules:**
- `main`: production releases only
- `develop`: integration for next release
- `release/*`: release preparation (QA, version bumps)
- `hotfix/*`: emergency production fixes

**Best for:** Versioned products, multiple deployment environments

---

## Trunk-Based Development (Large Teams, Full CI/CD)

```
main          ← always deployable, short-lived branches only
└── feat/short-lived-branch  (< 1 day, use Feature Flags)
```

**Best for:** Large teams with fully automated CI/CD pipelines

---

## Useful Branch Commands

```bash
# Create and switch to a new branch
git checkout -b feat/42-oauth-login

# Push branch to remote
git push -u origin feat/42-oauth-login

# Delete local branch after merge
git branch -d feat/42-oauth-login

# Clean up stale remote tracking branches
git fetch --prune

# List all branches (including remote)
git branch -a
```

---

## Recommended Branch Protection Rules (GitHub)

Apply to `main`:
- Require pull request before merging
- Require at least 1 approving review
- Require status checks to pass (CI)
- Restrict direct pushes