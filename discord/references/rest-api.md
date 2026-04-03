# Discord REST API Reference

## Base URL & Version

```
https://discord.com/api/v10
```

## Auth Headers

```
Authorization: Bot {BOT_TOKEN}
Content-Type: application/json
```

## Key Endpoints

### Messages

| Method | Endpoint | Description |
|---|---|---|
| POST | `/channels/{id}/messages` | Send a message |
| GET | `/channels/{id}/messages` | List messages |
| DELETE | `/channels/{id}/messages/{msg_id}` | Delete a message |
| PATCH | `/channels/{id}/messages/{msg_id}` | Edit a message |

### Channels

| Method | Endpoint | Description |
|---|---|---|
| GET | `/channels/{id}` | Get channel info |
| GET | `/guilds/{id}/channels` | List guild channels |

### Slash Commands

| Method | Endpoint | Description |
|---|---|---|
| POST | `/applications/{app_id}/commands` | Register global command |
| GET | `/applications/{app_id}/commands` | List commands |
| DELETE | `/applications/{app_id}/commands/{cmd_id}` | Delete command |

## Send Message Example

```bash
curl -X POST "https://discord.com/api/v10/channels/$CHANNEL_ID/messages" \
  -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Message sent via REST API"}'
```

```python
import requests, os
from dotenv import load_dotenv
load_dotenv()

BASE = "https://discord.com/api/v10"
HEADERS = {
    "Authorization": f"Bot {os.getenv('DISCORD_BOT_TOKEN')}",
    "Content-Type": "application/json"
}

def send_message(channel_id: str, content: str):
    url = f"{BASE}/channels/{channel_id}/messages"
    res = requests.post(url, json={"content": content}, headers=HEADERS)
    res.raise_for_status()
    return res.json()
```

## Rate Limit Handling

```python
import time

def request_with_retry(method, url, **kwargs):
    while True:
        res = requests.request(method, url, headers=HEADERS, **kwargs)
        if res.status_code == 429:
            retry_after = res.json().get('retry_after', 1)
            time.sleep(retry_after)
            continue
        res.raise_for_status()
        return res.json()
```

## Error Codes

| Code | Meaning |
|---|---|
| 401 | Invalid or missing token |
| 403 | Missing permissions |
| 404 | Channel or message not found |
| 429 | Rate limit exceeded |
| 50013 | Missing Permissions |