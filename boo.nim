import os, osproc, strutils, sequtils, json, std/strformat

# load the .env file into the environment
for line in lines(".env"):
  if line.len > 0 and not line.startsWith("#"):
    let parts = line.split('=', maxsplit = 1)
    if parts.len == 2:
      let key = parts[0].strip()
      let value = parts[1].strip()
      putEnv(key, value)

proc sendRequest(http_method: string, url: string, data: string, headers: seq[string]): string =
  let headerFlags = headers.map(proc(x: string): string = fmt"-H '{x}'").join(" ")
  let cmd = fmt"curl -s -X {http_method} {headerFlags} -d '{data}' {url}"
  let (output, exitCode) = execCmdEx(cmd)
  # echo "Request: ", cmd
  echo "Output: ", output
  return output

proc getToken(): string =
  let url = "https://securetoken.googleapis.com/v1/token?key=" & getEnv("GOOGLE_KEY")
  let data = "grant_type=refresh_token&refresh_token=" & getEnv("GOOGLE_TOKEN")
  let headers = @["Content-Type: application/x-www-form-urlencoded"]
  return sendRequest("POST", url, data, headers)

proc getProfiles(token: string): string =
  let url = "https://api.prod.boo.dating/v1/user/dailyProfiles"
  let headers = @["Authorization: " & token]
  return sendRequest("GET", url, "", headers)

proc sendLike(id, token: string): string =
  let url = "https://api.prod.boo.dating/v1/user/sendLike"
  let headers = @["Authorization: " & token, "Content-Type: application/json"]
  let data = "{\"user\": \"" & id & "\"}"
  return sendRequest("PATCH", url, data, headers)

let token = getToken().parseJson["access_token"].getStr
let profiles = getProfiles(token).parseJson["profiles"]
for profile in profiles:
  let id = profile["_id"].getStr
  let name = profile["firstName"].getStr
  echo "Liking ", name, "..."
  let response = sendLike(id, token)
  echo "Response: ", response