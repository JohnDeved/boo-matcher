import os, strutils, json, httpclient, uri

# load the .env file into the environment
for line in lines(".env"):
  if line.len > 0 and not line.startsWith("#"):
    let parts = line.split('=', maxsplit = 1)
    if parts.len == 2: putEnv(parts[0].strip(), parts[1].strip())

proc getToken(): string =
  return newHttpClient(headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"}))
    .post(
      "https://securetoken.googleapis.com/v1/token?key=" & getEnv("GOOGLE_KEY"), 
      "grant_type=refresh_token&refresh_token=" & getEnv("GOOGLE_TOKEN")
    )
    .body.parseJson["access_token"].getStr

proc getProfiles(token: string): JsonNode =
  return newHttpClient(headers = newHttpHeaders({"Authorization": token}))
    .get("https://api.prod.boo.dating/v1/user/dailyProfiles")
    .body.parseJson["profiles"]

proc sendLike(id, token: string): string =
  return newHttpClient(headers = newHttpHeaders({"Authorization": token, "Content-Type": "application/json"}))
    .patch("https://api.prod.boo.dating/v1/user/sendLike", $ %*{"user": id})
    .body

let token = getToken()
let profiles = getProfiles(token)
echo "Found ", profiles.len, " profiles to like"
for profile in profiles:
  echo "Liking ", profile["firstName"].getStr, "..."
  echo "Response: ", sendLike(profile["_id"].getStr, token)