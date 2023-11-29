#!/bin/bash

if [ -f .env ]; then
  # Export the variables
  export $(grep -v '^#' .env | xargs)
fi

if [ -z "$GOOGLE_KEY" ] || [ -z "$GOOGLE_TOKEN" ]; then
  echo "The GOOGLE_KEY and GOOGLE_TOKEN environment variables must be set."
  exit 1
fi

get_token() {
  local url="https://securetoken.googleapis.com/v1/token?key=$GOOGLE_KEY"
  local data="grant_type=refresh_token&refresh_token=$GOOGLE_TOKEN"

  response=$(curl -s -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d $data $url)
  echo $response | jq -r '.access_token'
}

get_profiles() {
  local token=$1
  local url="https://api.prod.boo.dating/v1/user/dailyProfiles"
  local headers=("Authorization: $token" "Content-Type: application/json" "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36")

  response=$(curl -s -X GET -H "${headers[0]}" -H "${headers[1]}" -H "${headers[2]}" $url)
  echo $response | jq -c '.profiles[]'
}

send_like() {
  local id=$1
  local token=$2
  local url="https://api.prod.boo.dating/v1/user/sendLike"
  local headers=("Authorization: $token" "Content-Type: application/json" "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36")
  local data="{\"user\": \"$id\"}"

  response=$(curl -s -w "\n%{http_code}" -X PATCH -H "${headers[0]}" -H "${headers[1]}" -H "${headers[2]}" -d "$data" $url)
  http_code=$(tail -n1 <<< "$response")
  body=$(sed '$d' <<< "$response")

  
  echo "HTTP status code: $http_code"
  echo "Response body: $body"
}

main() {
  token=$(get_token)
  profiles=$(get_profiles $token)
  while IFS= read -r profile; do
    id=$(echo $profile | jq -r '._id')
    name=$(echo $profile | jq -r '.firstName')
    echo "Liking $name..."
    send_like $id $token
  done <<< "$profiles"
}

main