import os, http.client, json, urllib.parse

# load the .env file into the environment
with open('.env', 'r') as f:
    for line in f:
        if line.strip()[0] != '#':
            key, value = line.strip().split('=', 1)
            os.environ[key] = value

def make_request(method: str, url: str, headers: dict[str, str], body: str | None = None) -> str:
    url_parts = urllib.parse.urlparse(url)
    conn = http.client.HTTPSConnection(url_parts.netloc)
    conn.request(method, f"{url_parts.path}?{url_parts.query}", body, headers)
    return conn.getresponse().read().decode()

def get_token() -> str:
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    body = f"grant_type=refresh_token&refresh_token={os.environ['GOOGLE_TOKEN']}"
    data = make_request("POST", f"https://securetoken.googleapis.com/v1/token?key={os.environ['GOOGLE_KEY']}", headers, body)
    return json.loads(data)['access_token']

def get_profiles(token: str) -> list[dict[str, str]]:
    headers = {'Authorization': token}
    data = make_request("GET", "https://api.prod.boo.dating/v1/user/dailyProfiles", headers)
    return json.loads(data)['profiles']

def send_like(id: str, token: str) -> str:
    headers = {'Authorization': token, 'Content-Type': 'application/json'}
    body = json.dumps({'user': id})
    return make_request("PATCH", "https://api.prod.boo.dating/v1/user/sendLike", headers, body)

token = get_token()
profiles = get_profiles(token)
print("Found ", len(profiles), " profiles to like")
for profile in profiles:
    print("Liking ", profile["firstName"], "...")
    print("Response: ", send_like(profile["_id"], token))