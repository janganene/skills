---
name: discord-js
description: >
  Build Discord bots using discord.js v14 (Node.js).
  Use this skill when writing a JavaScript or TypeScript Discord bot, creating slash commands
  with SlashCommandBuilder, handling gateway events (messageCreate, interactionCreate, guildMemberAdd, etc.),
  deploying commands via REST, building buttons and select menus, using message component collectors,
  configuring GatewayIntentBits, working with embeds, or managing guilds/members/roles programmatically.
  Triggers: "discord.js", "JavaScript Discord bot", "slash command builder", "interactionCreate",
  "GatewayIntentBits", "ButtonBuilder", "EmbedBuilder", "REST deploy", "discord.js v14".
---

# discord.js v14

Official docs: https://discord.js.org  
Guide: https://discordjs.guide  
Requires Node.js 16.11.0+

```
npm install discord.js
```

---

## Setup

### Project structure (recommended)

```
bot/
  commands/
    ping.js
    kick.js
  events/
    ready.js
    interactionCreate.js
  deploy-commands.js
  index.js
  config.json
```

### config.json

```json
{
  "token": "YOUR_BOT_TOKEN",
  "clientId": "YOUR_APPLICATION_CLIENT_ID",
  "guildId": "YOUR_TEST_GUILD_ID"
}
```

---

## Client initialization

`GatewayIntentBits` controls which gateway events the bot receives.
Always specify only what is needed — avoid enabling all intents unnecessarily.

```js
const { Client, GatewayIntentBits, Partials, Collection } = require('discord.js');

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,             // guild info, channels, roles
    GatewayIntentBits.GuildMembers,       // member join/leave/update (Privileged)
    GatewayIntentBits.GuildMessages,      // messageCreate, messageUpdate, messageDelete
    GatewayIntentBits.MessageContent,     // access message.content (Privileged)
    GatewayIntentBits.GuildMessageReactions, // reactionAdd/Remove
    GatewayIntentBits.DirectMessages,     // DM events
  ],
  partials: [Partials.Channel],           // required for DM events
});

client.commands = new Collection();
```

Privileged intents (GuildMembers, MessageContent, Presences) must also be enabled in the
Discord Developer Portal under Bot -> Privileged Gateway Intents.

---

## Events

In v14, all built-in event names are accessed via the `Events` enum.
Do not use raw string event names.

```js
const { Events } = require('discord.js');

client.once(Events.ClientReady, (readyClient) => {
  console.log(`Logged in as ${readyClient.user.tag}`);
});

client.on(Events.MessageCreate, (message) => {
  if (message.author.bot) return;
  console.log(message.content);
});

client.on(Events.GuildMemberAdd, (member) => {
  console.log(`${member.user.tag} joined ${member.guild.name}`);
});

client.on(Events.GuildMemberRemove, (member) => {
  console.log(`${member.user.tag} left`);
});

client.on(Events.MessageReactionAdd, (reaction, user) => {
  console.log(`${user.tag} reacted with ${reaction.emoji.name}`);
});

client.login(token);
```

Common `Events` values:

| Enum value                        | Fired when                              |
|-----------------------------------|-----------------------------------------|
| `Events.ClientReady`              | Bot connected and ready                 |
| `Events.MessageCreate`            | New message posted                      |
| `Events.MessageUpdate`            | Message edited                          |
| `Events.MessageDelete`            | Message deleted                         |
| `Events.InteractionCreate`        | Slash command / button / select used    |
| `Events.GuildMemberAdd`           | Member joined (requires GuildMembers)   |
| `Events.GuildMemberRemove`        | Member left (requires GuildMembers)     |
| `Events.GuildMemberUpdate`        | Member updated (nick, role, timeout...) |
| `Events.MessageReactionAdd`       | Reaction added                          |
| `Events.GuildAuditLogEntryCreate` | Audit log entry created (v14+)          |

---

## Slash Commands

### Define a command

Each command is a separate file exporting `data` (SlashCommandBuilder) and `execute`.

```js
// commands/ping.js
const { SlashCommandBuilder } = require('discord.js');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Replies with Pong!'),

  async execute(interaction) {
    const latency = interaction.client.ws.ping;
    await interaction.reply(`Pong! Latency: ${latency}ms`);
  },
};
```

### Command with options

```js
// commands/greet.js
const { SlashCommandBuilder } = require('discord.js');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('greet')
    .setDescription('Greet a user')
    .addUserOption((opt) =>
      opt.setName('target').setDescription('User to greet').setRequired(true)
    )
    .addStringOption((opt) =>
      opt.setName('message').setDescription('Custom message').setRequired(false)
    ),

  async execute(interaction) {
    const target = interaction.options.getUser('target');
    const msg = interaction.options.getString('message') ?? 'Hello!';
    await interaction.reply(`${msg}, ${target}!`);
  },
};
```

Option types: `addStringOption`, `addIntegerOption`, `addNumberOption`, `addBooleanOption`,
`addUserOption`, `addChannelOption`, `addRoleOption`, `addMentionableOption`, `addAttachmentOption`.

### String option with choices

```js
.addStringOption((opt) =>
  opt.setName('color')
    .setDescription('Pick a color')
    .setRequired(true)
    .addChoices(
      { name: 'Red',   value: 'red'   },
      { name: 'Green', value: 'green' },
      { name: 'Blue',  value: 'blue'  },
    )
)
```

### Subcommands

```js
new SlashCommandBuilder()
  .setName('config')
  .setDescription('Bot config')
  .addSubcommand((sub) =>
    sub.setName('set').setDescription('Set a value')
      .addStringOption((opt) => opt.setName('key').setDescription('Key').setRequired(true))
  )
  .addSubcommand((sub) =>
    sub.setName('get').setDescription('Get a value')
  )
```

```js
const sub = interaction.options.getSubcommand(); // 'set' or 'get'
```

---

## Deploy Commands (REST)

Run `deploy-commands.js` once whenever command definitions change.

```js
// deploy-commands.js
const { REST, Routes } = require('discord.js');
const { token, clientId, guildId } = require('./config.json');
const fs   = require('node:fs');
const path = require('node:path');

const commands = [];
const commandsPath = path.join(__dirname, 'commands');
for (const file of fs.readdirSync(commandsPath).filter((f) => f.endsWith('.js'))) {
  const command = require(path.join(commandsPath, file));
  commands.push(command.data.toJSON());
}

const rest = new REST().setToken(token);

(async () => {
  // Guild-scoped: instant, for development
  await rest.put(Routes.applicationGuildCommands(clientId, guildId), { body: commands });
  console.log('Guild commands registered.');

  // Global: takes up to 1 hour to propagate
  // await rest.put(Routes.applicationCommands(clientId), { body: commands });
})();
```

---

## Interaction Handler

```js
// index.js (interactionCreate section)
const { Events } = require('discord.js');

client.on(Events.InteractionCreate, async (interaction) => {
  if (interaction.isChatInputCommand()) {
    const command = client.commands.get(interaction.commandName);
    if (!command) return;
    try {
      await command.execute(interaction);
    } catch (error) {
      console.error(error);
      const reply = { content: 'An error occurred.', flags: MessageFlags.Ephemeral };
      if (interaction.replied || interaction.deferred) {
        await interaction.followUp(reply);
      } else {
        await interaction.reply(reply);
      }
    }
    return;
  }

  if (interaction.isButton()) {
    // handle button interactions
  }

  if (interaction.isStringSelectMenu()) {
    // handle select menu interactions
  }
});
```

---

## Interaction Responses

### Reply

```js
await interaction.reply('Pong!');

// Ephemeral (only visible to command executor)
const { MessageFlags } = require('discord.js');
await interaction.reply({ content: 'Only you can see this.', flags: MessageFlags.Ephemeral });
```

### Deferred reply (for operations > 3 seconds)

Discord requires a response within 3 seconds. Defer first, then follow up.

```js
await interaction.deferReply();                    // shows "Bot is thinking..."
await doSomethingSlow();
await interaction.editReply('Done!');              // replaces the deferred message

// Deferred ephemeral
await interaction.deferReply({ flags: MessageFlags.Ephemeral });
```

### Follow-up

```js
await interaction.reply('First response.');
await interaction.followUp('Additional message.');
await interaction.followUp({ content: 'Ephemeral follow-up.', flags: MessageFlags.Ephemeral });
```

Note: the first `followUp` after a `deferReply` edits the "thinking..." message.
Subsequent `followUp` calls create new messages.
Interaction tokens are valid for 15 minutes after the initial response.

### Edit and delete reply

```js
await interaction.editReply('Updated content.');
await interaction.deleteReply();
```

### Fetch reply message (with API call savings)

```js
const response = await interaction.reply({ content: 'Pong!', withResponse: true });
const message = response.resource.message;
```

---

## Embeds

```js
const { EmbedBuilder } = require('discord.js');

const embed = new EmbedBuilder()
  .setTitle('Server Info')
  .setDescription('Current statistics')
  .setColor(0x5865F2)
  .addFields(
    { name: 'Members', value: String(guild.memberCount), inline: true },
    { name: 'Channels', value: String(guild.channels.cache.size), inline: true },
  )
  .setThumbnail(guild.iconURL())
  .setFooter({ text: 'Updated', iconURL: client.user.displayAvatarURL() })
  .setTimestamp();

await interaction.reply({ embeds: [embed] });
```

---

## Buttons and Action Rows

```js
const { ButtonBuilder, ButtonStyle, ActionRowBuilder, ComponentType, MessageFlags } = require('discord.js');

const confirm = new ButtonBuilder()
  .setCustomId('confirm')
  .setLabel('Confirm')
  .setStyle(ButtonStyle.Success);

const cancel = new ButtonBuilder()
  .setCustomId('cancel')
  .setLabel('Cancel')
  .setStyle(ButtonStyle.Danger);

const row = new ActionRowBuilder().addComponents(confirm, cancel);

const response = await interaction.reply({
  content: 'Are you sure?',
  components: [row],
  withResponse: true,
});

// Collect one button press from the same user
try {
  const confirmation = await response.resource.message.awaitMessageComponent({
    filter: (i) => i.user.id === interaction.user.id,
    componentType: ComponentType.Button,
    time: 30_000,
  });

  if (confirmation.customId === 'confirm') {
    await confirmation.update({ content: 'Action confirmed.', components: [] });
  } else {
    await confirmation.update({ content: 'Cancelled.', components: [] });
  }
} catch {
  await interaction.editReply({ content: 'Timed out.', components: [] });
}
```

Button styles:

| Style                   | Color   | Use case                     |
|-------------------------|---------|------------------------------|
| `ButtonStyle.Primary`   | Blue    | Main action                  |
| `ButtonStyle.Secondary` | Gray    | Neutral / cancel             |
| `ButtonStyle.Success`   | Green   | Confirm / positive           |
| `ButtonStyle.Danger`    | Red     | Destructive / irreversible   |
| `ButtonStyle.Link`      | Gray    | External URL (no customId)   |

---

## Select Menus

```js
const { StringSelectMenuBuilder, StringSelectMenuOptionBuilder, ActionRowBuilder } = require('discord.js');

const select = new StringSelectMenuBuilder()
  .setCustomId('role-select')
  .setPlaceholder('Choose a role...')
  .setMinValues(1)
  .setMaxValues(2)
  .addOptions(
    new StringSelectMenuOptionBuilder().setLabel('Admin').setValue('admin').setDescription('Full access'),
    new StringSelectMenuOptionBuilder().setLabel('Member').setValue('member'),
    new StringSelectMenuOptionBuilder().setLabel('Guest').setValue('guest'),
  );

const row = new ActionRowBuilder().addComponents(select);
await interaction.reply({ content: 'Select a role:', components: [row] });
```

Handle in interactionCreate:

```js
if (interaction.isStringSelectMenu() && interaction.customId === 'role-select') {
  const selected = interaction.values; // string[]
  await interaction.reply(`You selected: ${selected.join(', ')}`);
}
```

---

## Message Component Collectors

Use when you want to collect multiple interactions from a component over time.

```js
const { ComponentType } = require('discord.js');

const collector = message.createMessageComponentCollector({
  componentType: ComponentType.Button,
  time: 60_000,                           // 60 seconds
});

collector.on('collect', async (i) => {
  if (i.user.id !== interaction.user.id) {
    await i.reply({ content: 'Not your button.', flags: MessageFlags.Ephemeral });
    return;
  }
  await i.update({ content: `Clicked: ${i.customId}` });
});

collector.on('end', (collected) => {
  console.log(`Collected ${collected.size} interactions.`);
});
```

---

## Moderation

### Kick a member

```js
async execute(interaction) {
  const member = interaction.options.getMember('target');
  const reason = interaction.options.getString('reason') ?? 'No reason provided';

  if (!member.kickable) {
    return interaction.reply({ content: 'Cannot kick this member.', flags: MessageFlags.Ephemeral });
  }

  await member.kick(reason);
  await interaction.reply(`Kicked ${member.user.tag}. Reason: ${reason}`);
}
```

### Ban a member

```js
await member.ban({ deleteMessageSeconds: 86400, reason: 'Spamming' });
await interaction.reply(`Banned ${member.user.tag}.`);
```

### Timeout a member

```js
// Timeout for 10 minutes
await member.timeout(10 * 60 * 1000, 'Breaking rules');

// Remove timeout
await member.timeout(null);
```

### Manage roles

```js
await member.roles.add(role);
await member.roles.remove(role);
```

---

## Sending Messages to Channels

```js
// Fetch and send to a channel by ID
const channel = await client.channels.fetch('CHANNEL_ID');
await channel.send('Hello!');
await channel.send({ embeds: [embed] });

// Send from within a command
await interaction.channel.send('Message in the same channel.');
```

---

## Permissions

```js
const { PermissionFlagsBits } = require('discord.js');

// Check before acting
if (!interaction.memberPermissions.has(PermissionFlagsBits.KickMembers)) {
  return interaction.reply({ content: 'You lack kick permissions.', flags: MessageFlags.Ephemeral });
}

// Require permissions on command definition
new SlashCommandBuilder()
  .setName('ban')
  .setDescription('Ban a member')
  .setDefaultMemberPermissions(PermissionFlagsBits.BanMembers)
```

---

## Error handling

```js
process.on('unhandledRejection', (error) => {
  console.error('Unhandled rejection:', error);
});

client.on(Events.Error, (error) => {
  console.error('Client error:', error);
});
```

---

## v14 breaking changes to remember

These are the most common mistakes when migrating from v13:

| v13                           | v14                                  |
|-------------------------------|--------------------------------------|
| `Intents.FLAGS.Guilds`        | `GatewayIntentBits.Guilds`           |
| `partials: ['CHANNEL']`       | `partials: [Partials.Channel]`       |
| `type: 'CHAT_INPUT'`          | `ApplicationCommandType.ChatInput`   |
| `type: 'STRING'` (option)     | `ApplicationCommandOptionType.String`|
| `style: 'PRIMARY'`            | `ButtonStyle.Primary`                |
| `ephemeral: true`             | `flags: MessageFlags.Ephemeral`      |
| `componentType: 'BUTTON'`     | `componentType: ComponentType.Button`|
| `client.on('ready', ...)`     | `client.once(Events.ClientReady, ...)`|
| `client.on('message', ...)`   | `client.on(Events.MessageCreate, ...)`|
| `MessageEmbed`                | `EmbedBuilder`                       |
| `MessageActionRow`            | `ActionRowBuilder`                   |
| `MessageButton`               | `ButtonBuilder`                      |
| `fetchReply: true`            | `withResponse: true`                 |
