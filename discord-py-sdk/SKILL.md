---
name: discord-py-sdk
description: >
  Build Discord bots using the discord.py Python SDK (v2.x).
  Use this skill when writing a Python Discord bot, handling gateway events (on_message, on_member_join,
  on_reaction_add, etc.), creating slash commands with app_commands, configuring Intents,
  using the commands.Bot extension, managing cogs, or working with discord.py's async API.
  Triggers: "discord.py", "Python Discord bot", "slash command", "on_message event",
  "discord.Client", "commands.Bot", "cog", "app_commands", "gateway intents".
---

# discord.py SDK (v2.x)

Official docs: https://discordpy.readthedocs.io/en/stable/  
Install: `pip install discord.py`  
Requires Python 3.8+

---

## Core concepts

discord.py provides two main client classes:

- `discord.Client` — low-level, handles raw gateway events
- `discord.ext.commands.Bot` — higher-level, adds prefix commands, cogs, and checks

Both accept an `intents` argument which controls which gateway events are received.

---

## Intents

Intents are required to receive specific gateway events. Always configure before connecting.

```python
import discord

# Recommended default: all except presences, members, message_content
intents = discord.Intents.default()

# Full access (requires approval in Developer Portal for presences/members/message_content)
intents = discord.Intents.all()

# Manual selection
intents = discord.Intents.default()
intents.members = True          # on_member_join, on_member_remove, on_member_update
intents.message_content = True  # access message.content in on_message
intents.presences = True        # presence/status updates
```

Privileged intents (members, presences, message_content) must also be enabled in the
Discord Developer Portal under Bot -> Privileged Gateway Intents.

---

## discord.Client (low-level)

Use when you need full control without the commands extension.

```python
import discord

intents = discord.Intents.default()
intents.message_content = True

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f"Logged in as {client.user} (ID: {client.user.id})")

@client.event
async def on_message(message: discord.Message):
    if message.author == client.user:
        return
    if message.content.startswith("!hello"):
        await message.channel.send(f"Hello, {message.author.mention}!")

client.run("YOUR_BOT_TOKEN")
```

---

## commands.Bot (recommended)

Provides prefix commands, cogs, checks, and hooks.

```python
import discord
from discord.ext import commands

intents = discord.Intents.default()
intents.message_content = True
intents.members = True

bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f"Ready as {bot.user}")

@bot.command()
async def ping(ctx: commands.Context):
    await ctx.send(f"Pong! Latency: {round(bot.latency * 1000)}ms")

bot.run("YOUR_BOT_TOKEN")
```

### Bot constructor parameters

| Parameter        | Type                     | Description                                   |
|------------------|--------------------------|-----------------------------------------------|
| `command_prefix` | str or callable or list  | Prefix(es) that trigger commands              |
| `intents`        | `discord.Intents`        | Required. Gateway intents to subscribe to     |
| `help_command`   | `HelpCommand` or None    | Built-in help. Pass `None` to disable         |
| `description`    | str                      | Shown in default help output                  |
| `owner_id`       | int                      | User ID of the bot owner (for `is_owner()`)   |
| `case_insensitive` | bool                   | If True, commands are case-insensitive        |

---

## Prefix Commands

```python
@bot.command(name="greet", aliases=["hello", "hi"])
async def greet(ctx: commands.Context, *, name: str = "there"):
    await ctx.send(f"Hello, {name}!")

@bot.command()
async def info(ctx: commands.Context, member: discord.Member = None):
    member = member or ctx.author
    embed = discord.Embed(title=member.display_name, color=member.color)
    embed.set_thumbnail(url=member.display_avatar.url)
    embed.add_field(name="Joined", value=member.joined_at.strftime("%Y-%m-%d"))
    await ctx.send(embed=embed)
```

### Converters

discord.py automatically converts arguments:

```python
@bot.command()
async def kick(ctx, member: discord.Member, *, reason: str = "No reason"):
    await member.kick(reason=reason)
    await ctx.send(f"Kicked {member.mention}. Reason: {reason}")
```

Built-in converters: `discord.Member`, `discord.User`, `discord.TextChannel`,
`discord.Role`, `discord.Emoji`, `int`, `float`.

---

## Slash Commands (app_commands)

Slash commands use `discord.app_commands` and require syncing to Discord.

```python
import discord
from discord import app_commands

intents = discord.Intents.default()
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)

@client.event
async def on_ready():
    await tree.sync()  # sync globally (takes up to 1 hour to propagate)
    print(f"Synced commands. Logged in as {client.user}")

@tree.command(name="hello", description="Greet someone")
@app_commands.describe(name="The name to greet")
async def hello(interaction: discord.Interaction, name: str = "World"):
    await interaction.response.send_message(f"Hello, {name}!")

client.run("YOUR_BOT_TOKEN")
```

### Sync to a specific guild (instant, for development)

```python
GUILD_ID = discord.Object(id=YOUR_GUILD_ID)

@client.event
async def on_ready():
    tree.copy_global_to(guild=GUILD_ID)
    await tree.sync(guild=GUILD_ID)
```

### Slash command with choices

```python
@tree.command(name="color", description="Pick a color")
@app_commands.choices(color=[
    app_commands.Choice(name="Red",   value="red"),
    app_commands.Choice(name="Green", value="green"),
    app_commands.Choice(name="Blue",  value="blue"),
])
async def color(interaction: discord.Interaction, color: app_commands.Choice[str]):
    await interaction.response.send_message(f"You chose {color.name}.")
```

### Ephemeral response (visible only to the user)

```python
await interaction.response.send_message("Only you can see this.", ephemeral=True)
```

### Deferred response (for long operations)

```python
@tree.command()
async def slow(interaction: discord.Interaction):
    await interaction.response.defer()         # acknowledge within 3 seconds
    await some_long_operation()
    await interaction.followup.send("Done!")   # send actual response
```

---

## Gateway Events

Events fired by discord.py when gateway events are received.
Register with `@client.event` or `@bot.event`.

### Connection events

```python
@bot.event
async def on_ready():
    # Fired when the bot has fully connected and cached guild data.
    # May fire multiple times on reconnect.
    print(f"Ready: {bot.user}")
```

### Message events

```python
@bot.event
async def on_message(message: discord.Message):
    # Requires Intents.message_content for message.content access.
    if message.author.bot:
        return
    await bot.process_commands(message)  # required when overriding on_message with commands.Bot

@bot.event
async def on_message_edit(before: discord.Message, after: discord.Message):
    pass

@bot.event
async def on_message_delete(message: discord.Message):
    pass
```

### Member events

```python
@bot.event
async def on_member_join(member: discord.Member):
    # Requires Intents.members
    channel = member.guild.system_channel
    if channel:
        await channel.send(f"Welcome {member.mention}!")

@bot.event
async def on_member_remove(member: discord.Member):
    # Requires Intents.members
    pass

@bot.event
async def on_member_update(before: discord.Member, after: discord.Member):
    # Fires on nickname, role, timeout, avatar, or flag changes.
    # Requires Intents.members
    pass
```

### Reaction events

```python
@bot.event
async def on_reaction_add(reaction: discord.Reaction, user: discord.Member | discord.User):
    # Requires Intents.reactions
    # For uncached messages use on_raw_reaction_add instead.
    pass

@bot.event
async def on_reaction_remove(reaction: discord.Reaction, user: discord.Member | discord.User):
    # Requires Intents.reactions and Intents.members
    pass
```

### Guild / channel events

```python
@bot.event
async def on_guild_channel_create(channel: discord.abc.GuildChannel):
    # Requires Intents.guilds
    pass

@bot.event
async def on_guild_channel_delete(channel: discord.abc.GuildChannel):
    pass

@bot.event
async def on_guild_channel_update(before, after):
    pass
```

### AutoMod events (v2.0+)

```python
@bot.event
async def on_automod_rule_create(rule: discord.AutoModRule):
    # Requires Intents.auto_moderation_configuration and manage_guild permission
    pass

@bot.event
async def on_automod_action(execution: discord.AutoModAction):
    # Requires Intents.auto_moderation_execution and manage_guild
    pass
```

---

## Cogs

Cogs are classes that group related commands and listeners. Use them to organize large bots.

```python
# cogs/moderation.py
import discord
from discord.ext import commands

class Moderation(commands.Cog):
    def __init__(self, bot: commands.Bot):
        self.bot = bot

    @commands.command()
    @commands.has_permissions(kick_members=True)
    async def kick(self, ctx: commands.Context, member: discord.Member, *, reason="No reason"):
        await member.kick(reason=reason)
        await ctx.send(f"Kicked {member.mention}.")

    @commands.Cog.listener()
    async def on_member_join(self, member: discord.Member):
        print(f"{member} joined {member.guild}")

async def setup(bot: commands.Bot):
    await bot.add_cog(Moderation(bot))
```

```python
# main.py
import asyncio

async def main():
    async with bot:
        await bot.load_extension("cogs.moderation")
        await bot.start("YOUR_BOT_TOKEN")

asyncio.run(main())
```

---

## Checks and Permissions

```python
from discord.ext import commands

@bot.command()
@commands.has_role("Admin")
async def secret(ctx):
    await ctx.send("Admin-only content.")

@bot.command()
@commands.has_permissions(manage_messages=True)
async def purge(ctx, amount: int):
    await ctx.channel.purge(limit=amount + 1)

@bot.command()
@commands.guild_only()
async def server_info(ctx):
    await ctx.send(ctx.guild.name)

@bot.command()
@commands.is_owner()
async def shutdown(ctx):
    await ctx.send("Shutting down.")
    await bot.close()
```

---

## Sending Messages and Embeds

```python
# Plain message
await channel.send("Hello!")

# Mention a user
await channel.send(f"Hey {member.mention}!")

# Embed
embed = discord.Embed(
    title="Server Stats",
    description="Current statistics",
    color=discord.Color.blue()
)
embed.add_field(name="Members", value=str(guild.member_count), inline=True)
embed.set_footer(text="Updated now")
embed.set_thumbnail(url=guild.icon.url)
await channel.send(embed=embed)

# File
file = discord.File("/path/to/file.png", filename="image.png")
await channel.send("Here is the file:", file=file)
```

---

## Common Patterns

### Wait for a user response

```python
@bot.command()
async def confirm(ctx: commands.Context):
    await ctx.send("Are you sure? (yes/no)")
    def check(m):
        return m.author == ctx.author and m.channel == ctx.channel
    try:
        msg = await bot.wait_for("message", timeout=30.0, check=check)
        if msg.content.lower() == "yes":
            await ctx.send("Confirmed.")
        else:
            await ctx.send("Cancelled.")
    except asyncio.TimeoutError:
        await ctx.send("Timed out.")
```

### Change bot presence

```python
@bot.event
async def on_ready():
    await bot.change_presence(
        status=discord.Status.online,
        activity=discord.Game(name="discord.py v2")
    )
```

Activity types: `discord.Game`, `discord.Streaming`, `discord.Activity`,
`discord.CustomActivity`.

---

## Error Handling

```python
@bot.event
async def on_command_error(ctx: commands.Context, error: commands.CommandError):
    if isinstance(error, commands.MissingPermissions):
        await ctx.send("You lack the required permissions.")
    elif isinstance(error, commands.MemberNotFound):
        await ctx.send("Member not found.")
    elif isinstance(error, commands.CommandNotFound):
        pass  # Silently ignore unknown commands
    else:
        raise error  # Re-raise unexpected errors for logging
```

---

## Version notes

- `discord.py` v2.x requires Python 3.8+ and is async-only.
- `discord.ext.commands.Bot` is a subclass of `discord.Client`.
- `app_commands.CommandTree` is separate from the prefix command system.
- Slash command syncing with `tree.sync()` is global (up to 1h propagation) or per-guild (instant).
- `on_message` must call `await bot.process_commands(message)` when using `commands.Bot`.
