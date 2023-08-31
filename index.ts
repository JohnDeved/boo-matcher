import { GOOGLE_KEY, GOOGLE_TOKEN } from "./config"
import { GoogleApisRes, ProfileListing } from "./types"

async function getToken () {
  const googleHeaders = new Headers()
  googleHeaders.append("Content-Type", "application/x-www-form-urlencoded")

  const googleBody = new URLSearchParams()
  googleBody.append("grant_type", "refresh_token")
  googleBody.append("refresh_token", GOOGLE_TOKEN)

  return fetch(`https://securetoken.googleapis.com/v1/token?key=${GOOGLE_KEY}`, {
    method: 'POST',
    headers: googleHeaders,
    body: googleBody,
  })
    .then<GoogleApisRes>(res => res.json())
}

async function getProfiles (token: string) {
  const profilesHeaders = new Headers()
  profilesHeaders.append("authorization", token)
  profilesHeaders.append("content-type", "application/json")
  profilesHeaders.append("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36")

  return fetch("https://api.prod.boo.dating/v1/user/dailyProfiles", {
    method: 'GET',
    headers: profilesHeaders,
  })
    .then<ProfileListing>(res => res.json())
}

async function sendLike (id: string, token: string) {
  var likeHeaders = new Headers();
  likeHeaders.append("authorization", token)
  likeHeaders.append("content-type", "application/json")
  likeHeaders.append("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36")

  fetch("https://api.prod.boo.dating/v1/user/sendLike", {
    method: 'PATCH',
    headers: likeHeaders,
    body: JSON.stringify({
      user: id
    }),
  })
    .then(response => response.json())
    .then(result => console.log(result))
} 

getToken().then(async google => {
  const { profiles } = await getProfiles(google.access_token)
  for (const profile of profiles) {
    console.log(`Liking ${profile.firstName}...`)
    await sendLike(profile._id, google.access_token)
  }
})