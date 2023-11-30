import { GOOGLE_KEY, GOOGLE_TOKEN } from "./config"
import { GoogleApisRes, ProfileListing } from "./types"

function getToken () {
  const googleHeaders = new Headers({ "Content-Type": "application/x-www-form-urlencoded" })
  const googleBody = new URLSearchParams({ grant_type: "refresh_token", refresh_token: GOOGLE_TOKEN })
  return fetch(`https://securetoken.googleapis.com/v1/token?key=${GOOGLE_KEY}`, { method: 'POST', headers: googleHeaders, body: googleBody })
    .then<GoogleApisRes>(res => res.json())
}

function getProfiles (token: string) {
  const profilesHeaders = new Headers({ authorization: token, "content-type": "application/json" })
  return fetch("https://api.prod.boo.dating/v1/user/dailyProfiles", { method: 'GET', headers: profilesHeaders })
    .then<ProfileListing>(res => res.json())
}

function sendLike (id: string, token: string) {
  const likeHeaders = new Headers({ authorization: token, "content-type": "application/json" })
  return fetch("https://api.prod.boo.dating/v1/user/sendLike", { method: 'PATCH', headers: likeHeaders, body: JSON.stringify({ user: id }) })
    .then(res => res.text())
} 

getToken().then(async google => {
  const { profiles } = await getProfiles(google.access_token)
  console.log(`Found ${profiles.length} profiles to like.`)
  for (const profile of profiles) {
    console.log(`Liking ${profile.firstName}...`)
    console.log(await sendLike(profile._id, google.access_token))
  }
})