#!/bin/bash
# discord.js environment check script (refactored for security)
echo "=== discord.js Environment Check ==="

# Check Node.js
if command -v node &> /dev/null; then
  NODE_VER=$(node -v)
  echo "Node.js: $NODE_VER"
else
  echo "Node.js is not installed. Visit https://nodejs.org to install."
  exit 1
fi

# Check discord.js and environment variables via runtime
node -e "
try {
  const dj = require('discord.js');
  console.log('discord.js: v' + dj.version);
  
  // Try loading dotenv if available
  try { require('dotenv').config(); } catch (e) {}
  
  if (process.env.DISCORD_BOT_TOKEN) {
    console.log('DISCORD_BOT_TOKEN is set in environment');
  } else {
    console.log('DISCORD_BOT_TOKEN is missing (check your .env file)');
  }
} catch (e) {
  console.log('discord.js not found. Run: npm install discord.js');
}
"

echo ""
echo "=== Check Complete ==="