#!/bin/bash
# discord.js environment check script
echo "=== discord.js Environment Check ==="

# Check Node.js
if command -v node &> /dev/null; then
  NODE_VER=$(node -v)
  echo "Node.js: $NODE_VER"
else
  echo "Node.js is not installed. Visit https://nodejs.org to install."
  exit 1
fi

# Check discord.js
if node -e "require('discord.js')" 2>/dev/null; then
  DJ_VER=$(node -e "console.log(require('discord.js').version)")
  echo "discord.js: v$DJ_VER"
else
  echo "discord.js not found. Run: npm install discord.js"
fi

# Check .env
if [ -f ".env" ]; then
  echo ".env file found"
  if grep -q "DISCORD_BOT_TOKEN" .env; then
    echo "DISCORD_BOT_TOKEN is set"
  else
    echo "DISCORD_BOT_TOKEN is missing from .env"
  fi
else
  echo ".env file not found"
fi

echo ""
echo "=== Check Complete ==="