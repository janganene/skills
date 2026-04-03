#!/usr/bin/env python3
"""discord.py environment check script"""
import sys
import os

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

# Check python-dotenv
try:
    import dotenv
    print("python-dotenv: installed")
except ImportError:
    print("python-dotenv not found. Run: pip install python-dotenv")

# Check .env file
if os.path.exists(".env"):
    print(".env file found")
    with open(".env") as f:
        content = f.read()
    if "DISCORD_BOT_TOKEN" in content:
        print("DISCORD_BOT_TOKEN is set")
    else:
        print("DISCORD_BOT_TOKEN is missing from .env")
else:
    print(".env file not found")

print("\n=== Check Complete ===")