import { GOOGLE_KEY, GOOGLE_TOKEN } from "./config"
import { GoogleApisRes } from "./types"

const googleHeaders = new Headers()
googleHeaders.append("Content-Type", "application/x-www-form-urlencoded")

const googleBody = new URLSearchParams()
googleBody.append("grant_type", "refresh_token")
googleBody.append("refresh_token", GOOGLE_TOKEN)

fetch(`https://securetoken.googleapis.com/v1/token?key=${GOOGLE_KEY}`, {
  method: 'POST',
  headers: googleHeaders,
  body: googleBody,
})
  .then<GoogleApisRes>(res => res.json())
  .then(google => {
    var profilesHeaders = new Headers();
    profilesHeaders.append("authorization", google.access_token);
    profilesHeaders.append("content-type", "application/json");
    profilesHeaders.append("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36");

    fetch("https://api.prod.boo.dating/v1/user/dailyProfiles", {
      method: 'GET',
      headers: profilesHeaders,
    })
      .then(res => res.json())
      .then(res => console.log(res))
  })