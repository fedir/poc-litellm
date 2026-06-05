#!/usr/bin/env python3
import urllib.request
import json
import sys
import os

MASTER_KEY = os.environ.get('LITELLM_MASTER_KEY', 'your-secure-master-key-here')
API_URL = 'http://localhost:8000/chat/completions'

payload = json.dumps({
    "model": "mistral/mistral-large-latest",
    "messages": [
        {"role": "user", "content": "Hello! Say something brief about yourself."}
    ],
    "max_tokens": 100,
    "temperature": 0.7
}).encode()

try:
    req = urllib.request.Request(
        API_URL,
        data=payload,
        headers={
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {MASTER_KEY}'
        }
    )

    with urllib.request.urlopen(req, timeout=10) as response:
        data = json.loads(response.read())

        print("✅ Mistral Large Model Test Successful")
        print("")
        print("Response:")
        print(f"  {data['choices'][0]['message']['content']}")
        print("")
        print(f"Tokens used: {data['usage']['total_tokens']}")
        sys.exit(0)

except urllib.error.HTTPError as e:
    print(f"❌ HTTP Error: {e.code}")
    try:
        error_data = json.loads(e.read())
        print(f"   Details: {error_data}")
    except:
        print(f"   {e.reason}")
    sys.exit(1)

except urllib.error.URLError as e:
    print(f"❌ Connection Error: {e.reason}")
    print("   Is the gateway running? Try: make start")
    sys.exit(1)

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)
