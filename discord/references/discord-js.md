# discord.js Reference

## Installation

```bash
npm install discord.js dotenv
# Requires Node.js 18+
```

## Basic Bot Structure

```js
// index.js
import { Client, GatewayIntentBits, Events } from 'discord.js';
import 'dotenv/config';

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent, // Enable in Developer Portal
  ],
});

client.once(Events.ClientReady, (c) => {
  console.log(`Logged in as ${c.user.tag}`);
});

client.on(Events.MessageCreate, async (message) => {
  if (message.author.bot) return;
  if (message.content === '!ping') {
    await message.reply('Pong!');
  }
});

client.login(process.env.DISCORD_BOT_TOKEN);
```

## Registering Slash Commands

```js
// deploy-commands.js
import { REST, Routes, SlashCommandBuilder } from 'discord.js';
import 'dotenv/config';

const commands = [
  new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Replies with Pong!')
    .toJSON(),
];

const rest = new REST().setToken(process.env.DISCORD_BOT_TOKEN);

await rest.put(
  Routes.applicationCommands(process.env.DISCORD_APP_ID),
  { body: commands }
);
```

## Handling Slash Commands

```js
client.on(Events.InteractionCreate, async (interaction) => {
  if (!interaction.isChatInputCommand()) return;

  if (interaction.commandName === 'ping') {
    await interaction.reply('Pong!');
  }
});
```

## Sending Embeds

```js
import { EmbedBuilder } from 'discord.js';

const embed = new EmbedBuilder()
  .setTitle('Title')
  .setDescription('Description')
  .setColor(0x5865F2)
  .addFields({ name: 'Field', value: 'Value', inline: true })
  .setTimestamp();

await message.channel.send({ embeds: [embed] });
```

## Common Patterns

- Send to a channel: `await channel.send('content')`
- Mention a user: `<@${user.id}>`
- Mention a role: `<@&${role.id}>`
- Defer for long tasks: `await interaction.deferReply()` → `await interaction.editReply('Done')`