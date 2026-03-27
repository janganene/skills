---
name: discord-bot
description: Design and build Discord bots — welcome systems, moderation, reaction roles, ticket systems, scheduled posts, AI chat integration, and n8n workflow automation.
---

# Discord Bot

Patterns for building Discord bots with community management, moderation, AI, and automation features.

> Use `discord-api` skill for raw API curl calls.  
> Official docs: https://discord.com/developers/docs

---

## Bot Setup

### Application & Token

1. [Discord Developer Portal](https://discord.com/developers/applications) → New Application
2. Bot section → Add Bot → Reset Token → save token securely
3. Enable Gateway Intents (Bot section):
   - `PRESENCE_INTENT` — user online status
   - `SERVER_MEMBERS_INTENT` — member list/join events
   - `MESSAGE_CONTENT_INTENT` — read message content
4. OAuth2 → URL Generator → scopes: `bot`, `applications.commands` → copy invite URL

### Recommended Libraries

| Language | Library | Install |
|----------|---------|---------|
| JavaScript | discord.js | `npm install discord.js` |
| Python | discord.py | `pip install discord.py` |
| Python | nextcord | `pip install nextcord` |
| Go | discordgo | `go get github.com/bwmarrin/discordgo` |

### Minimal Bot (discord.js)

```javascript
import { Client, GatewayIntentBits } from 'discord.js';

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildMembers,
  ],
});

client.once('ready', () => {
  console.log(`Logged in as ${client.user.tag}`);
});

client.on('messageCreate', (message) => {
  if (message.author.bot) return;
  if (message.content === '!ping') message.reply('Pong!');
});

client.login(process.env.DISCORD_BOT_TOKEN);
```

### Minimal Bot (discord.py)

```python
import discord
from discord.ext import commands
import os

intents = discord.Intents.default()
intents.message_content = True
intents.members = True

bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')

@bot.command()
async def ping(ctx):
    await ctx.reply('Pong!')

bot.run(os.environ['DISCORD_BOT_TOKEN'])
```

---

## Slash Commands

### Register commands (discord.js)

```javascript
import { REST, Routes, SlashCommandBuilder } from 'discord.js';

const commands = [
  new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Check bot latency'),

  new SlashCommandBuilder()
    .setName('poll')
    .setDescription('Create a poll')
    .addStringOption(opt =>
      opt.setName('question').setDescription('Poll question').setRequired(true)
    )
    .addStringOption(opt =>
      opt.setName('options').setDescription('Options separated by comma').setRequired(true)
    ),

  new SlashCommandBuilder()
    .setName('remind')
    .setDescription('Set a reminder')
    .addStringOption(opt =>
      opt.setName('time').setDescription('e.g. 10m, 1h, 2d').setRequired(true)
    )
    .addStringOption(opt =>
      opt.setName('message').setDescription('Reminder message').setRequired(true)
    ),
];

const rest = new REST().setToken(process.env.DISCORD_BOT_TOKEN);
await rest.put(Routes.applicationCommands(CLIENT_ID), { body: commands });
```

### Handle interactions

```javascript
client.on('interactionCreate', async (interaction) => {
  if (!interaction.isChatInputCommand()) return;

  if (interaction.commandName === 'ping') {
    const latency = Date.now() - interaction.createdTimestamp;
    await interaction.reply(`🏓 Pong! Latency: ${latency}ms`);
  }

  if (interaction.commandName === 'poll') {
    const question = interaction.options.getString('question');
    const options = interaction.options.getString('options').split(',');

    const embed = {
      title: `📊 ${question}`,
      description: options.map((o, i) => `${i + 1}. ${o.trim()}`).join('\n'),
      color: 0x5865F2,
    };

    const msg = await interaction.reply({ embeds: [embed], fetchReply: true });
    const emojis = ['1️⃣','2️⃣','3️⃣','4️⃣','5️⃣'];
    for (let i = 0; i < options.length; i++) {
      await msg.react(emojis[i]);
    }
  }
});
```

---

## Welcome System

```javascript
client.on('guildMemberAdd', async (member) => {
  const { guild } = member;

  // Assign default role
  const newMemberRole = guild.roles.cache.find(r => r.name === 'New Member');
  if (newMemberRole) await member.roles.add(newMemberRole);

  // Post in welcome channel
  const welcomeChannel = guild.channels.cache.find(c => c.name === 'welcome');
  if (welcomeChannel) {
    const embed = {
      title: `👋 Welcome to ${guild.name}!`,
      description: `Hey ${member}, glad you're here!`,
      color: 0x57F287,
      fields: [
        { name: '📜 Rules', value: '<#RULES_CHANNEL_ID>', inline: true },
        { name: '🎭 Roles', value: '<#ROLES_CHANNEL_ID>', inline: true },
        { name: '💬 Chat', value: '<#GENERAL_CHANNEL_ID>', inline: true },
      ],
      thumbnail: { url: member.user.displayAvatarURL() },
      footer: { text: `Member #${guild.memberCount}` },
    };
    welcomeChannel.send({ embeds: [embed] });
  }

  // Send DM
  await member.send({
    embeds: [{
      title: `Welcome to ${guild.name}!`,
      description: `Start by reading the rules and grabbing some roles.\nNeed help? Ask in #support.`,
      color: 0x5865F2,
    }],
  }).catch(() => {}); // DMs may be disabled
});

client.on('guildMemberRemove', (member) => {
  const logChannel = member.guild.channels.cache.find(c => c.name === 'logs');
  logChannel?.send(`📤 **${member.user.tag}** left the server.`);
});
```

---

## Moderation

### Commands

```javascript
// /warn
if (interaction.commandName === 'warn') {
  const target = interaction.options.getMember('user');
  const reason = interaction.options.getString('reason');

  warnings.set(target.id, (warnings.get(target.id) || 0) + 1);

  await target.send(`⚠️ You have been warned in **${guild.name}**: ${reason}`).catch(() => {});
  await logChannel.send(`⚠️ **${target.user.tag}** warned by ${interaction.user.tag} — ${reason}`);
  await interaction.reply({ content: `Warned ${target.user.tag}.`, ephemeral: true });
}

// /timeout
if (interaction.commandName === 'timeout') {
  const target = interaction.options.getMember('user');
  const minutes = interaction.options.getInteger('minutes');
  const reason = interaction.options.getString('reason');

  await target.timeout(minutes * 60 * 1000, reason);
  await interaction.reply(`🔇 ${target.user.tag} timed out for ${minutes}m — ${reason}`);
}

// /ban
if (interaction.commandName === 'ban') {
  const target = interaction.options.getMember('user');
  const reason = interaction.options.getString('reason') ?? 'No reason provided';

  await target.ban({ reason, deleteMessageSeconds: 86400 });
  await interaction.reply(`🔨 Banned **${target.user.tag}** — ${reason}`);
}
```

### Auto-moderation

```javascript
client.on('messageCreate', async (message) => {
  if (message.author.bot || !message.guild) return;

  // Spam detection: 5 messages in 5 seconds
  const key = message.author.id;
  const now = Date.now();
  if (!spamMap.has(key)) spamMap.set(key, []);
  const timestamps = spamMap.get(key).filter(t => now - t < 5000);
  timestamps.push(now);
  spamMap.set(key, timestamps);

  if (timestamps.length >= 5) {
    await message.member.timeout(5 * 60 * 1000, 'Spam detected');
    await message.channel.send(`🚫 ${message.author} timed out for spam.`);
    return;
  }

  // Word filter
  const blockedWords = ['badword1', 'badword2'];
  if (blockedWords.some(w => message.content.toLowerCase().includes(w))) {
    await message.delete();
    await message.author.send('Your message was removed for violating server rules.');
    return;
  }

  // Link filter
  const allowedDomains = ['youtube.com', 'github.com', 'discord.com'];
  const urlRegex = /https?:\/\/([^/]+)/g;
  const urls = [...message.content.matchAll(urlRegex)];
  for (const [, domain] of urls) {
    if (!allowedDomains.some(d => domain.endsWith(d))) {
      await message.delete();
      await message.reply('Links from that domain are not allowed here.').then(m => setTimeout(() => m.delete(), 5000));
      return;
    }
  }
});
```

---

## Reaction Roles

```javascript
const reactionRoles = {
  '🎮': 'ROLE_ID_GAMER',
  '💻': 'ROLE_ID_DEVELOPER',
  '🎨': 'ROLE_ID_ARTIST',
  '📚': 'ROLE_ID_STUDENT',
};

const REACTION_ROLE_MESSAGE_ID = 'MESSAGE_ID_HERE';

// Post the role picker message
async function postReactionRoleMessage(channel) {
  const embed = {
    title: '🎭 Pick Your Roles',
    description: Object.entries(reactionRoles)
      .map(([emoji]) => `${emoji} — get a role`)
      .join('\n'),
    color: 0x5865F2,
  };
  const msg = await channel.send({ embeds: [embed] });
  for (const emoji of Object.keys(reactionRoles)) await msg.react(emoji);
}

// Add role on reaction
client.on('messageReactionAdd', async (reaction, user) => {
  if (user.bot || reaction.message.id !== REACTION_ROLE_MESSAGE_ID) return;
  const roleId = reactionRoles[reaction.emoji.name];
  if (!roleId) return;
  const member = await reaction.message.guild.members.fetch(user.id);
  await member.roles.add(roleId);
});

// Remove role on reaction remove
client.on('messageReactionRemove', async (reaction, user) => {
  if (user.bot || reaction.message.id !== REACTION_ROLE_MESSAGE_ID) return;
  const roleId = reactionRoles[reaction.emoji.name];
  if (!roleId) return;
  const member = await reaction.message.guild.members.fetch(user.id);
  await member.roles.remove(roleId);
});
```

---

## Ticket System

```javascript
const { ButtonBuilder, ButtonStyle, ActionRowBuilder } = require('discord.js');

// Post open-ticket button
async function postTicketPanel(channel) {
  const button = new ButtonBuilder()
    .setCustomId('open_ticket')
    .setLabel('📩 Open a Ticket')
    .setStyle(ButtonStyle.Primary);

  await channel.send({
    content: 'Need help? Click the button to open a support ticket.',
    components: [new ActionRowBuilder().addComponents(button)],
  });
}

// Handle button click
client.on('interactionCreate', async (interaction) => {
  if (!interaction.isButton()) return;

  if (interaction.customId === 'open_ticket') {
    const { guild, user } = interaction;
    const existing = guild.channels.cache.find(c => c.name === `ticket-${user.username}`);
    if (existing) {
      return interaction.reply({ content: `You already have a ticket: ${existing}`, ephemeral: true });
    }

    const channel = await guild.channels.create({
      name: `ticket-${user.username}`,
      permissionOverwrites: [
        { id: guild.id, deny: ['ViewChannel'] },
        { id: user.id, allow: ['ViewChannel', 'SendMessages'] },
        { id: SUPPORT_ROLE_ID, allow: ['ViewChannel', 'SendMessages'] },
      ],
    });

    const closeButton = new ButtonBuilder()
      .setCustomId('close_ticket')
      .setLabel('🔒 Close Ticket')
      .setStyle(ButtonStyle.Danger);

    await channel.send({
      content: `${user} — describe your issue and a team member will assist you.`,
      components: [new ActionRowBuilder().addComponents(closeButton)],
    });

    await interaction.reply({ content: `Ticket opened: ${channel}`, ephemeral: true });
  }

  if (interaction.customId === 'close_ticket') {
    await interaction.reply('Closing ticket in 5 seconds...');
    setTimeout(() => interaction.channel.delete(), 5000);
  }
});
```

---

## Scheduled Posts

```javascript
import cron from 'node-cron';

// Daily question at 10am
cron.schedule('0 10 * * *', async () => {
  const channel = client.channels.cache.get(DISCUSSION_CHANNEL_ID);
  const questions = [
    'What are you working on today?',
    'Share something you learned this week.',
    'What's your favorite productivity tip?',
  ];
  const q = questions[Math.floor(Math.random() * questions.length)];
  channel?.send({ embeds: [{ title: '🤔 Question of the Day', description: q, color: 0xFEE75C }] });
});

// Weekly recap every Sunday at 6pm
cron.schedule('0 18 * * 0', async () => {
  const channel = client.channels.cache.get(ANNOUNCE_CHANNEL_ID);
  const guild = client.guilds.cache.get(GUILD_ID);
  channel?.send({
    embeds: [{
      title: '📊 Weekly Recap',
      fields: [
        { name: 'Members', value: `${guild.memberCount}`, inline: true },
      ],
      color: 0x5865F2,
    }],
  });
});
```

---

## AI Chat Integration

```javascript
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const conversationHistory = new Map(); // per-channel history

client.on('messageCreate', async (message) => {
  if (message.author.bot) return;
  if (!message.mentions.has(client.user)) return; // only reply when mentioned

  const channelId = message.channel.id;
  if (!conversationHistory.has(channelId)) conversationHistory.set(channelId, []);
  const history = conversationHistory.get(channelId);

  history.push({ role: 'user', content: message.content });
  if (history.length > 20) history.shift(); // keep last 20 messages

  await message.channel.sendTyping();

  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      {
        role: 'system',
        content: 'You are a helpful Discord bot. Be friendly, use Discord formatting, keep responses concise.',
      },
      ...history,
    ],
  });

  const reply = response.choices[0].message.content;
  history.push({ role: 'assistant', content: reply });

  // Split long replies across multiple messages
  const chunks = reply.match(/[\s\S]{1,2000}/g) ?? [reply];
  for (const chunk of chunks) await message.reply(chunk);
});
```

---

## n8n Workflow Automation

### GitHub release → Discord notification

```
Trigger:   GitHub — On Release Published
Action 1:  Discord — Send Channel Message
           Channel: #releases
           Embed:
             title:       🚀 New Release: {{ $json.tag_name }}
             description: {{ $json.body }}
             color:       0x57F287
             url:         {{ $json.html_url }}
```

### Twitch live → Discord alert

```
Trigger:   Twitch — On Stream Online
Action 1:  Discord — Send Channel Message
           Channel: #streams
           Content: @everyone {{ $json.user_name }} is now live!
           Embed:
             title: {{ $json.title }}
             image: {{ $json.thumbnail_url }}
             url:   https://twitch.tv/{{ $json.user_name }}
```

### New member → Google Sheets log

```
Trigger:   Discord — On Member Joined
Action 1:  Discord — Send Message (welcome)
Action 2:  Discord — Add Role
Action 3:  Google Sheets — Append Row
           Columns: [username, id, joined_at, guild]
```

### Scheduled digest

```
Trigger:   Schedule — Every Monday 9am
Action 1:  Google Sheets — Get Rows (weekly stats)
Action 2:  Discord — Send Embed to #announcements
```

---

## Embeds & Components

### Rich embed structure

```javascript
const embed = {
  title: 'Server Info',
  description: 'Welcome to the community!',
  color: 0x5865F2,                            // Discord blurple
  url: 'https://example.com',
  thumbnail: { url: guild.iconURL() },
  image: { url: 'https://example.com/banner.png' },
  fields: [
    { name: '👥 Members', value: `${guild.memberCount}`, inline: true },
    { name: '💬 Channels', value: `${guild.channels.cache.size}`, inline: true },
    { name: '🎭 Roles', value: `${guild.roles.cache.size}`, inline: true },
  ],
  footer: { text: 'Last updated', icon_url: client.user.displayAvatarURL() },
  timestamp: new Date().toISOString(),
};

channel.send({ embeds: [embed] });
```

### Button row

```javascript
const { ButtonBuilder, ButtonStyle, ActionRowBuilder } = require('discord.js');

const row = new ActionRowBuilder().addComponents(
  new ButtonBuilder().setCustomId('confirm').setLabel('✅ Confirm').setStyle(ButtonStyle.Success),
  new ButtonBuilder().setCustomId('cancel').setLabel('❌ Cancel').setStyle(ButtonStyle.Danger),
  new ButtonBuilder().setLabel('Docs').setURL('https://discord.js.org').setStyle(ButtonStyle.Link),
);

channel.send({ content: 'Are you sure?', components: [row] });
```

### Select menu

```javascript
const { StringSelectMenuBuilder } = require('discord.js');

const menu = new StringSelectMenuBuilder()
  .setCustomId('category')
  .setPlaceholder('Choose a category')
  .addOptions([
    { label: 'General', value: 'general', emoji: '💬' },
    { label: 'Tech', value: 'tech', emoji: '💻' },
    { label: 'Gaming', value: 'gaming', emoji: '🎮' },
  ]);

channel.send({ components: [new ActionRowBuilder().addComponents(menu)] });
```

---

## Best Practices

- Store token in environment variable, never hardcode
- Check `message.author.bot` before processing every message
- Use `interaction.reply({ ephemeral: true })` for mod-only responses
- Wrap DM sends in try/catch — users can disable DMs
- Keep conversation history per-channel to avoid cross-channel leakage
- Rate limit AI responses per user to control API costs
- Use cron or `setInterval` for scheduled tasks — not `setTimeout` chains
- Log moderation actions to a private mod-log channel
