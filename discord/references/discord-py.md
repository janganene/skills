# discord.py Reference

## Installation

```bash
pip install "discord.py[voice]" python-dotenv
# Requires Python 3.8+
```

## Basic Bot Structure

```python
# bot.py
import discord
from discord.ext import commands
from dotenv import load_dotenv
import os

load_dotenv()

intents = discord.Intents.default()
intents.message_content = True  # Enable in Developer Portal

bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')

@bot.command(name='ping')
async def ping(ctx):
    await ctx.reply('Pong!')

bot.run(os.getenv('DISCORD_BOT_TOKEN'))
```

## Slash Commands (app_commands)

```python
from discord import app_commands

@bot.tree.command(name='ping', description='Replies with Pong!')
async def slash_ping(interaction: discord.Interaction):
    await interaction.response.send_message('Pong!')

@bot.event
async def on_ready():
    await bot.tree.sync()  # Register commands globally
    print(f'Logged in as {bot.user}')
```

## Sending Embeds

```python
embed = discord.Embed(
    title='Title',
    description='Description',
    color=discord.Color.blurple()
)
embed.add_field(name='Field', value='Value', inline=True)
embed.set_footer(text='Footer')

await ctx.send(embed=embed)
```

## Cogs (Modularization)

```python
# cogs/general.py
from discord.ext import commands

class General(commands.Cog):
    def __init__(self, bot):
        self.bot = bot

    @commands.command()
    async def hello(self, ctx):
        await ctx.send('Hello!')

async def setup(bot):
    await bot.add_cog(General(bot))
```

```python
# Load in bot.py
await bot.load_extension('cogs.general')
```

## Common Patterns

- Send to a specific channel: `channel = bot.get_channel(id); await channel.send('...')`
- Send a DM: `await user.send('...')`
- Error handling: `@bot.event async def on_command_error(ctx, error)`
- Defer for long responses: `await interaction.response.defer()` → `await interaction.followup.send('Done')`