#!/bin/bash
# Commit message Conventional Commits validator
# Usage: bash scripts/validate_commit.sh "feat(auth): add login"
# Without argument: validates the latest commit message

MSG="${1:-$(git log -1 --pretty=%s 2>/dev/null)}"

if [ -z "$MSG" ]; then
  echo "No commit message provided."
  echo "Usage: bash scripts/validate_commit.sh \"feat(auth): add login\""
  exit 1
fi

echo "Validating: \"$MSG\""

# Conventional Commits pattern
PATTERN="^(feat|fix|docs|style|refactor|test|chore|perf|ci|revert)(\([a-z0-9_-]+\))?(!)?: .{1,72}$"

if echo "$MSG" | grep -qE "$PATTERN"; then
  echo "Valid commit message."

  # Detect breaking change
  if echo "$MSG" | grep -qE "!:"; then
    echo "Breaking Change detected. Add a BREAKING CHANGE description in the footer."
  fi

  exit 0
else
  echo "Commit message does not follow Conventional Commits."
  echo ""
  echo "Correct format:"
  echo "  <type>(<scope>): <subject>"
  echo ""
  echo "Valid types: feat, fix, docs, style, refactor, test, chore, perf, ci, revert"
  echo ""
  echo "Examples:"
  echo "  feat(auth): add OAuth2 login"
  echo "  fix(api): handle null response"
  echo "  docs: update README"
  exit 1
fi