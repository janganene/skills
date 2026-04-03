# Pull Request Writing Guide

## What Makes a Good PR

1. **Focused scope** — one purpose per PR
2. **Sufficient description** — reviewers can understand context without asking
3. **Testable** — clear steps to verify the change
4. **Small size** — aim for under 300 lines changed (larger PRs get lower-quality reviews)

## PR Title Convention

Use the same format as commit messages:
```
feat(discord): add slash command support (#42)
fix(webhook): handle null response on rate limit (#87)
```

## PR Body Structure

See `resources/PR_TEMPLATE.md` for the ready-to-use template.

### What (What was changed?)
- List changes as bullet points
- Include key technical decisions made

### Why (Why was this change needed?)
- Explain the problem or requirement
- Link the related issue: `Closes #42` or `Refs #87`

### How to Test (How to verify?)
- Step-by-step, reproducible test instructions
- State the expected result

### Screenshots (Optional)
- Before/After screenshots for UI changes
- Bot response examples if applicable

## Review Etiquette

- **Draft PR**: Open as `Draft` when you need early feedback on a work-in-progress
- **Ready for Review**: Convert from Draft once complete
- When mentioning a reviewer, include a specific question: `@reviewer could you check if the rate limit handling here is correct?`
- Respond to every review comment — acknowledge, address, or explain why not

## Pre-Merge Checklist

```
- [ ] Branch name follows the convention
- [ ] Commit messages follow Conventional Commits
- [ ] CI passes
- [ ] At least one reviewer has approved
- [ ] Related documentation is updated
- [ ] Tests are added or updated
- [ ] Breaking changes include a migration guide
```

## Merge Strategy

| Strategy | When to use |
|---|---|
| **Squash and merge** | Small features, keeps history clean |
| **Rebase and merge** | Maintains a linear commit history |
| **Merge commit** | When branch history needs to be preserved |

> Pick one strategy per repo and stay consistent. Default recommendation: **Squash and merge**