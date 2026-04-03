#!/bin/bash
# Branch name convention validator
# Usage: bash scripts/validate_branch.sh "feat/42-oauth-login"
# Without argument: validates the current branch name

BRANCH="${1:-$(git branch --show-current 2>/dev/null)}"

if [ -z "$BRANCH" ]; then
  echo "Could not determine branch name."
  exit 1
fi

echo "Validating: \"$BRANCH\""

# Allow reserved branch names
if echo "$BRANCH" | grep -qE "^(main|develop|master|release/.+|hotfix/.+)$"; then
  echo "Reserved branch name: $BRANCH"
  exit 0
fi

# Convention pattern: type/[issue-]description
PATTERN="^(feat|fix|docs|style|refactor|test|chore|perf|ci|revert)/([0-9]+-)?[a-z0-9][a-z0-9-]*[a-z0-9]$"

if echo "$BRANCH" | grep -qE "$PATTERN"; then
  echo "Valid branch name."
else
  echo "Branch name does not follow the convention."
  echo ""
  echo "Correct format:"
  echo "  <type>/[issue-number-]<short-description>"
  echo ""
  echo "Examples:"
  echo "  feat/42-oauth-login"
  echo "  fix/87-webhook-null-error"
  echo "  docs/update-readme"
  echo "  chore/upgrade-discordjs"
  exit 1
fi