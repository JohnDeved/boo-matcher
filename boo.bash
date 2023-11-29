#!/bin/bash

if [ -f .env ]; then
  # Export the variables
  export $(grep -v '^#' .env | xargs)
fi

if [ -z "$GOOGLE_KEY" ] || [ -z "$GOOGLE_TOKEN" ]; then
  echo "The GOOGLE_KEY and GOOGLE_TOKEN environment variables must be set."
  exit 1
fi

send_request() {
  local method=$1
  local url=$2
  local data=$3
  local headers=("${@:4}")
  local header_flags=()

  for header in "${headers[@]}"; do
    header_flags+=("-H" "$header")
  done

  echo "curl -s -X $method $header_flags -d \"$data\" $url" >&2
  response=$(curl -s -X $method "${header_flags[@]}" -d "$data" $url)

  echo $response
}

get_token() {
  local url="https://securetoken.googleapis.com/v1/token?key=$GOOGLE_KEY"
  local data="grant_type=refresh_token&refresh_token=$GOOGLE_TOKEN"
  local headers=("Content-Type: application/x-www-form-urlencoded")

  send_request "POST" $url $data "${headers[@]}" 
}

get_profiles() {
  local token=$1
  local url="https://api.prod.boo.dating/v1/user/dailyProfiles"
  local headers=("Authorization: $token")

  send_request "GET" $url "" "${headers[@]}"
}

send_like() {
  local id=$1
  local token=$2
  local url="https://api.prod.boo.dating/v1/user/sendLike"
  local headers=("Authorization: $token" "Content-Type: application/json")
  local data="{\"user\": \"$id\"}"

  send_request "PATCH" "$url" "$data" "${headers[@]}"
}

main() {
  token=$(get_token | jq -r '.access_token')
  profiles=$(get_profiles $token | jq -c '.profiles[]')

  while IFS= read -r profile; do
    id=$(echo $profile | jq -r '._id')
    name=$(echo $profile | jq -r '.firstName')
    echo "Liking $name..."
    response=$(send_like $id $token)
    echo "Response: $response"
  done <<< "$profiles"
}

main