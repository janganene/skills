# Discord Webhook Reference

## Getting a Webhook URL

Channel Settings → Integrations → Webhooks → New Webhook → Copy URL

## Basic Message Sending

### curl
```bash
curl -X POST "$DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello from a webhook!"}'
```

### Python (requests)
```python
import requests
import os
from dotenv import load_dotenv

load_dotenv()

def send_webhook(content: str):
    url = os.getenv('DISCORD_WEBHOOK_URL')
    payload = {"content": content}
    response = requests.post(url, json=payload)
    response.raise_for_status()
```

### Node.js (fetch)
```js
import 'dotenv/config';

async function sendWebhook(content) {
  const res = await fetch(process.env.DISCORD_WEBHOOK_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ content }),
  });
  if (!res.ok) throw new Error(`Discord error: ${res.status}`);
}
```

## Sending Embeds

```json
{
  "username": "Notifier",
  "avatar_url": "https://example.com/icon.png",
  "embeds": [{
    "title": "Deployment Successful",
    "description": "v1.2.3 has been deployed successfully.",
    "color": 3066993,
    "fields": [
      { "name": "Environment", "value": "Production", "inline": true },
      { "name": "Time", "value": "2026-04-03 12:00", "inline": true }
    ],
    "footer": { "text": "CI/CD Notifier" },
    "timestamp": "2026-04-03T12:00:00.000Z"
  }]
}
```

## File Attachments

```python
with open('log.txt', 'rb') as f:
    requests.post(url, files={'file': f}, data={'content': 'Log attached'})
```

## Rate Limits

- Webhooks: 30 requests per 60 seconds
- On HTTP 429, wait for `retry_after` seconds before retrying