#!/usr/bin/env python3
"""discord.py environment check script"""
import sys
import os

try:
    from dotenv import load_dotenv
    DOTENV_AVAILABLE = True
except ImportError:
    DOTENV_AVAILABLE = False

print("=== discord.py Environment Check ===")

# Check Python version
version = sys.version_info
if version >= (3, 8):
    print(f"Python: {sys.version.split()[0]}")
else:
    print(f"Python 3.8+ required (current: {sys.version.split()[0]})")
    sys.exit(1)

# Check discord.py
try:
    import discord
    print(f"discord.py: v{discord.__version__}")
except ImportError:
    print("discord.py not found. Run: pip install discord.py")

# Check python-dotenv and load .env
if DOTENV_AVAILABLE:
    print("python-dotenv: installed")
    load_dotenv()  # Load variables from .env if present
else:
    print("python-dotenv not found. Run: pip install python-dotenv")

# Check DISCORD_BOT_TOKEN via environment variable
if os.getenv("DISCORD_BOT_TOKEN"):
    print("DISCORD_BOT_TOKEN is set")
else:
    if os.path.exists(".env"):
        print(".env file exists but DISCORD_BOT_TOKEN is not set or python-dotenv is missing")
    else:
        print(".env file not found and DISCORD_BOT_TOKEN not set in environment")

print("\n=== Check Complete ===")