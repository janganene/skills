---
name: discord-py-sdk
description: >
  Build Discord bots using the discord.py Python SDK (v2.x).
  Use this skill when writing a Python Discord bot, handling gateway events (on_message,
  on_member_join, on_reaction_add, etc.), creating slash commands with app_commands,
  configuring Intents, using commands.Bot, managing cogs, or working with discord.py's async API.
  Do not use for JavaScript/TypeScript bots — use discord-js instead.
  Triggers: "discord.py", "Python Discord bot", "slash command", "on_message event",
  "discord.Client", "commands.Bot", "cog", "app_commands", "gateway intents".
compatibility:
  runtime: Python 3.8+
  package: discord.py>=2.0
---

# discord.py SDK (v2.x)

Docs: https://discordpy.readthedocs.io/en/stable/
Install: `pip install discord.py`

---

## Core client classes

| Class | Use when |
|---|---|
| `discord.Client` | Low-level, raw gateway events, full control |
| `commands.Bot` | High-level, adds prefix commands, cogs, checks |

Both require an `intents` argument.

---

## Intents

```python
import discord

intents = discord.Intents.default()        # recommended base
intents.members = True                     # on_member_join/remove/update (Privileged)
intents.message_content = True            # access message.content  (Privileged)
intents.presences = True                  # presence/status updates (Privileged)
```

> Privileged intents must also be enabled in Discord Developer Portal
> → Bot → Privileged Gateway Intents.

---

## discord.Client (low-level)

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

### Constructor parameters

| Parameter | Description |
|---|---|
| `command_prefix` | str, callable, or list |
| `intents` | `discord.Intents` (required) |
| `help_command` | Pass `None` to disable built-in help |
| `owner_id` | int — enables `@commands.is_owner()` |
| `case_insensitive` | bool — case-insensitive prefix commands |

---

## Prefix Commands

```python
@bot.command(name="greet", aliases=["hello", "hi"])
async def greet(ctx: commands.Context, *, name: str = "there"):
    await ctx.send(f"Hello, {name}!")

@bot.command()
async def kick(ctx, member: discord.Member, *, reason: str = "No reason"):
    await member.kick(reason=reason)
    await ctx.send(f"Kicked {member.mention}. Reason: {reason}")
```

Built-in converters: `discord.Member` `discord.User` `discord.TextChannel`
`discord.Role` `discord.Emoji` `int` `float`

---

## Slash Commands (app_commands)

```python
import discord
from discord import app_commands

intents = discord.Intents.default()
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)

@client.event
async def on_ready():
    await tree.sync()       # global sync — up to 1h to propagate
    print(f"Synced. Logged in as {client.user}")

@tree.command(name="hello", description="Greet someone")
@app_commands.describe(name="The name to greet")
async def hello(interaction: discord.Interaction, name: str = "World"):
    await interaction.response.send_message(f"Hello, {name}!")

client.run("YOUR_BOT_TOKEN")
```

### Guild-scoped sync (instant, for development)

```python
GUILD_ID = discord.Object(id=YOUR_GUILD_ID)

@client.event
async def on_ready():
    tree.copy_global_to(guild=GUILD_ID)
    await tree.sync(guild=GUILD_ID)
```

### Choices and ephemeral

```python
@tree.command()
@app_commands.choices(color=[
    app_commands.Choice(name="Red", value="red"),
    app_commands.Choice(name="Blue", value="blue"),
])
async def color(interaction: discord.Interaction, color: app_commands.Choice[str]):
    await interaction.response.send_message(f"You chose {color.name}.", ephemeral=True)
```

### Deferred response (operations > 3 s)

```python
@tree.command()
async def slow(interaction: discord.Interaction):
    await interaction.response.defer()      # acknowledge within 3 s
    await some_long_operation()
    await interaction.followup.send("Done!")
```

---

## Gateway Events

```python
# Connection
@bot.event
async def on_ready():
    print(f"Ready: {bot.user}")  # may fire multiple times on reconnect

# Messages  (requires intents.message_content)
@bot.event
async def on_message(message: discord.Message):
    if message.author.bot:
        return
    await bot.process_commands(message)  # required with commands.Bot

@bot.event
async def on_message_edit(before: discord.Message, after: discord.Message): ...
@bot.event
async def on_message_delete(message: discord.Message): ...

# Members  (requires intents.members)
@bot.event
async def on_member_join(member: discord.Member):
    if channel := member.guild.system_channel:
        await channel.send(f"Welcome {member.mention}!")

@bot.event
async def on_member_remove(member: discord.Member): ...
@bot.event
async def on_member_update(before: discord.Member, after: discord.Member): ...

# Reactions  (requires intents.reactions)
@bot.event
async def on_reaction_add(reaction: discord.Reaction, user): ...
@bot.event
async def on_reaction_remove(reaction: discord.Reaction, user): ...
```

---

## Cogs

Cogs group related commands and listeners. Use them to organize large bots.

```python
# cogs/moderation.py
import discord
from discord.ext import commands

class Moderation(commands.Cog):
    def __init__(self, bot: commands.Bot):
        self.bot = bot

    @commands.command()
    @commands.has_permissions(kick_members=True)
    async def kick(self, ctx, member: discord.Member, *, reason="No reason"):
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

## Checks & Permissions

```python
@bot.command()
@commands.has_role("Admin")
async def secret(ctx): ...

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

## Sending Messages & Embeds

```python
await channel.send("Hello!")
await channel.send(f"Hey {member.mention}!")

embed = discord.Embed(title="Stats", color=discord.Color.blue())
embed.add_field(name="Members", value=str(guild.member_count), inline=True)
embed.set_footer(text="Updated now")
await channel.send(embed=embed)

file = discord.File("/path/to/file.png", filename="image.png")
await channel.send("Here it is:", file=file)
```

---

## Common Patterns

### Wait for user input

```python
@bot.command()
async def confirm(ctx):
    await ctx.send("Are you sure? (yes/no)")
    def check(m): return m.author == ctx.author and m.channel == ctx.channel
    try:
        msg = await bot.wait_for("message", timeout=30.0, check=check)
        await ctx.send("Confirmed." if msg.content.lower() == "yes" else "Cancelled.")
    except asyncio.TimeoutError:
        await ctx.send("Timed out.")
```

### Change presence

```python
await bot.change_presence(
    status=discord.Status.online,
    activity=discord.Game(name="discord.py v2")
)
```

---

## Error Handling

```python
@bot.event
async def on_command_error(ctx, error):
    if isinstance(error, commands.MissingPermissions):
        await ctx.send("You lack the required permissions.")
    elif isinstance(error, commands.MemberNotFound):
        await ctx.send("Member not found.")
    elif isinstance(error, commands.CommandNotFound):
        pass
    else:
        raise error
```

---

## Version Notes

- v2.x requires Python 3.8+ and is fully async.
- `commands.Bot` is a subclass of `discord.Client`.
- `app_commands.CommandTree` is separate from the prefix command system.
- `on_message` must call `await bot.process_commands(message)` with `commands.Bot`.
- Use `tree.sync(guild=...)` for instant registration during development.
