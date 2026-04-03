---
name: discord-js
description: >
  Build Discord bots using discord.js v14 (Node.js / TypeScript).
  Use this skill when writing a JavaScript or TypeScript Discord bot, creating slash commands
  with SlashCommandBuilder, handling gateway events (messageCreate, interactionCreate,
  guildMemberAdd, etc.), deploying commands via REST, building buttons and select menus,
  using message component collectors, configuring GatewayIntentBits, working with embeds,
  or managing guilds / members / roles programmatically.
  Do not use for Python Discord bots — use discord-py-sdk instead.
  Triggers: "discord.js", "JavaScript Discord bot", "TypeScript Discord bot",
  "slash command builder", "interactionCreate", "GatewayIntentBits", "ButtonBuilder",
  "EmbedBuilder", "REST deploy commands", "discord.js v14".
compatibility:
  runtime: Node.js 16.11.0+
  package: discord.js@14
---

# discord.js v14

Official docs: https://discord.js.org
Guide: https://discordjs.guide
Install: `npm install discord.js`

---

## Setup

### Recommended project structure

```
bot/
  commands/       ← one file per slash command
  events/         ← one file per event
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
Enable only what is needed — avoid enabling all intents.

```js
const { Client, GatewayIntentBits, Partials, Collection } = require('discord.js');

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,                // guild info, channels, roles
    GatewayIntentBits.GuildMembers,          // join/leave/update (Privileged)
    GatewayIntentBits.GuildMessages,         // messageCreate, messageUpdate, messageDelete
    GatewayIntentBits.MessageContent,        // access message.content (Privileged)
    GatewayIntentBits.GuildMessageReactions, // reactionAdd/Remove
    GatewayIntentBits.DirectMessages,        // DM events
  ],
  partials: [Partials.Channel],              // required for DM events
});

client.commands = new Collection();
```

> Privileged intents (GuildMembers, MessageContent, Presences) must also be enabled in
> Discord Developer Portal → Bot → Privileged Gateway Intents.

---

## Events

In v14 use the `Events` enum — never raw string event names.

```js
const { Events } = require('discord.js');

client.once(Events.ClientReady, (c) => console.log(`Logged in as ${c.user.tag}`));
client.on(Events.MessageCreate, (msg) => { if (!msg.author.bot) console.log(msg.content); });
client.on(Events.GuildMemberAdd, (member) => console.log(`${member.user.tag} joined`));
client.on(Events.MessageReactionAdd, (reaction, user) =>
  console.log(`${user.tag} reacted with ${reaction.emoji.name}`)
);

client.login(token);
```

Common `Events` values:

| Enum | Fires when |
|---|---|
| `Events.ClientReady` | Bot connected and ready |
| `Events.MessageCreate` | New message posted |
| `Events.InteractionCreate` | Slash command / button / select used |
| `Events.GuildMemberAdd` | Member joined (requires GuildMembers) |
| `Events.GuildMemberRemove` | Member left |
| `Events.GuildMemberUpdate` | Member nick/role/timeout changed |
| `Events.MessageReactionAdd` | Reaction added |
| `Events.GuildAuditLogEntryCreate` | Audit log entry created (v14+) |

---

## Slash Commands

### Define a command

```js
// commands/ping.js
const { SlashCommandBuilder } = require('discord.js');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Replies with Pong!'),

  async execute(interaction) {
    await interaction.reply(`Pong! Latency: ${interaction.client.ws.ping}ms`);
  },
};
```

### Command with options

```js
new SlashCommandBuilder()
  .setName('greet')
  .setDescription('Greet a user')
  .addUserOption((o) => o.setName('target').setDescription('Who to greet').setRequired(true))
  .addStringOption((o) => o.setName('message').setDescription('Custom message'))
```

Option types: `addStringOption` `addIntegerOption` `addNumberOption` `addBooleanOption`
`addUserOption` `addChannelOption` `addRoleOption` `addAttachmentOption`

### String choices

```js
.addStringOption((o) =>
  o.setName('color').setDescription('Pick a color').setRequired(true)
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
  .addSubcommand((s) => s.setName('set').setDescription('Set value')
    .addStringOption((o) => o.setName('key').setDescription('Key').setRequired(true)))
  .addSubcommand((s) => s.setName('get').setDescription('Get value'))

// In handler:
const sub = interaction.options.getSubcommand(); // 'set' | 'get'
```

---

## Deploy Commands (REST)

Run `deploy-commands.js` once whenever command definitions change.

```js
const { REST, Routes } = require('discord.js');
const { token, clientId, guildId } = require('./config.json');
const fs = require('node:fs'), path = require('node:path');

const commands = fs.readdirSync(path.join(__dirname, 'commands'))
  .filter((f) => f.endsWith('.js'))
  .map((f) => require(path.join(__dirname, 'commands', f)).data.toJSON());

const rest = new REST().setToken(token);

(async () => {
  // Guild-scoped — instant, use for development
  await rest.put(Routes.applicationGuildCommands(clientId, guildId), { body: commands });

  // Global — propagates in up to 1 hour, use for production
  // await rest.put(Routes.applicationCommands(clientId), { body: commands });
})();
```

---

## Interaction Handler

```js
const { Events, MessageFlags } = require('discord.js');

client.on(Events.InteractionCreate, async (interaction) => {
  if (interaction.isChatInputCommand()) {
    const cmd = client.commands.get(interaction.commandName);
    if (!cmd) return;
    try {
      await cmd.execute(interaction);
    } catch (err) {
      console.error(err);
      const msg = { content: 'An error occurred.', flags: MessageFlags.Ephemeral };
      interaction.replied || interaction.deferred
        ? await interaction.followUp(msg)
        : await interaction.reply(msg);
    }
    return;
  }
  if (interaction.isButton()) { /* handle buttons */ }
  if (interaction.isStringSelectMenu()) { /* handle select menus */ }
});
```

---

## Interaction Responses

```js
// Plain reply
await interaction.reply('Pong!');

// Ephemeral
const { MessageFlags } = require('discord.js');
await interaction.reply({ content: 'Only you see this.', flags: MessageFlags.Ephemeral });

// Deferred (long operations — respond within 3 s)
await interaction.deferReply();
await doSomethingSlow();
await interaction.editReply('Done!');

// Follow-up
await interaction.followUp('Additional message.');

// Edit / delete
await interaction.editReply('Updated.');
await interaction.deleteReply();
```

Interaction tokens are valid for **15 minutes** after the initial response.

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

## Buttons & Action Rows

```js
const { ButtonBuilder, ButtonStyle, ActionRowBuilder, ComponentType, MessageFlags } = require('discord.js');

const row = new ActionRowBuilder().addComponents(
  new ButtonBuilder().setCustomId('confirm').setLabel('Confirm').setStyle(ButtonStyle.Success),
  new ButtonBuilder().setCustomId('cancel').setLabel('Cancel').setStyle(ButtonStyle.Danger),
);

const resp = await interaction.reply({ content: 'Sure?', components: [row], withResponse: true });

try {
  const btn = await resp.resource.message.awaitMessageComponent({
    filter: (i) => i.user.id === interaction.user.id,
    componentType: ComponentType.Button,
    time: 30_000,
  });
  await btn.update({ content: btn.customId === 'confirm' ? 'Confirmed.' : 'Cancelled.', components: [] });
} catch {
  await interaction.editReply({ content: 'Timed out.', components: [] });
}
```

Button styles: `Primary` (blue) · `Secondary` (gray) · `Success` (green) · `Danger` (red) · `Link` (external URL)

---

## Select Menus

```js
const { StringSelectMenuBuilder, StringSelectMenuOptionBuilder, ActionRowBuilder } = require('discord.js');

const select = new StringSelectMenuBuilder()
  .setCustomId('role-select')
  .setPlaceholder('Choose a role...')
  .addOptions(
    new StringSelectMenuOptionBuilder().setLabel('Admin').setValue('admin'),
    new StringSelectMenuOptionBuilder().setLabel('Member').setValue('member'),
  );

await interaction.reply({ content: 'Pick a role:', components: [new ActionRowBuilder().addComponents(select)] });

// In interactionCreate:
if (interaction.isStringSelectMenu() && interaction.customId === 'role-select') {
  await interaction.reply(`Selected: ${interaction.values.join(', ')}`);
}
```

---

## Moderation

```js
// Kick
if (!member.kickable) return interaction.reply({ content: 'Cannot kick.', flags: MessageFlags.Ephemeral });
await member.kick(reason);

// Ban  (deleteMessageSeconds max 604800)
await member.ban({ deleteMessageSeconds: 86400, reason });

// Timeout  (ms — 10 minutes)
await member.timeout(10 * 60 * 1000, 'Breaking rules');
await member.timeout(null);  // remove timeout

// Roles
await member.roles.add(role);
await member.roles.remove(role);
```

---

## Permissions

```js
const { PermissionFlagsBits } = require('discord.js');

if (!interaction.memberPermissions.has(PermissionFlagsBits.KickMembers))
  return interaction.reply({ content: 'Missing permissions.', flags: MessageFlags.Ephemeral });

// Restrict command to members with BanMembers permission
new SlashCommandBuilder()
  .setName('ban')
  .setDefaultMemberPermissions(PermissionFlagsBits.BanMembers)
```

---

## Error Handling

```js
process.on('unhandledRejection', (err) => console.error('Unhandled:', err));
client.on(Events.Error, (err) => console.error('Client error:', err));
```

---

## v14 Migration Reference

| v13 | v14 |
|---|---|
| `Intents.FLAGS.Guilds` | `GatewayIntentBits.Guilds` |
| `partials: ['CHANNEL']` | `partials: [Partials.Channel]` |
| `ephemeral: true` | `flags: MessageFlags.Ephemeral` |
| `fetchReply: true` | `withResponse: true` |
| `MessageEmbed` | `EmbedBuilder` |
| `MessageActionRow` | `ActionRowBuilder` |
| `MessageButton` | `ButtonBuilder` |
| `client.on('ready', ...)` | `client.once(Events.ClientReady, ...)` |
| `client.on('message', ...)` | `client.on(Events.MessageCreate, ...)` |
