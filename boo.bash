#!/bin/bash

export $(grep -v '^#' .env | xargs)

TOKEN=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=refresh_token&refresh_token=$GOOGLE_TOKEN" \
  "https://securetoken.googleapis.com/v1/token?key=$GOOGLE_KEY" | jq -r '.access_token')

PROFILES=$(curl -s -H "Authorization: $TOKEN" "https://api.prod.boo.dating/v1/user/dailyProfiles" | jq '.profiles')

echo "Found $(echo $PROFILES | jq length) profiles to like"

for id in $(echo $PROFILES | jq -r '.[] ._id'); do
  echo "Liking $(echo $PROFILES | jq -r ".[] | select(._id == \"$id\") | .firstName")..."
  echo "Response: $(curl -s -X PATCH -H "Authorization: $TOKEN" -H "Content-Type: application/json" \
    -d "{\"user\": \"$id\"}" "https://api.prod.boo.dating/v1/user/sendLike")"
done