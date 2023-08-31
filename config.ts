import {config} from 'dotenv'
config()

export const GOOGLE_TOKEN = process.env.GOOGLE_TOKEN ?? ''
export const GOOGLE_KEY = process.env.GOOGLE_KEY ?? ''