export interface GoogleApisRes {
  access_token: string
  expires_in: string
  token_type: string
  refresh_token: string
  id_token: string
  user_id: string
  project_id: string
}

export interface ProfileListing {
  profiles: Profile[]
}

export interface Profile {
  _id: string
  firstName: string
  pictures: any[]
  profilePicture: string
  personality: any[]
  gender: string
  age: number
  description: string
  education: string
  work: string
  moreAboutUser: any[]
  prompts: any[]
  crown: boolean
  handle: string
  location: string
  teleport: boolean
  preferences: any[]
  hideQuestions: boolean
  hideComments: boolean
  horoscope: string
  interests: any[]
  interestNames: any[]
  karma: number
  numFollowers: number
  verified: boolean
  verificationStatus: string
  languages: any[]
  timezone: string
  hidden: boolean
  stories: any[]
}