$env:GOOGLE_KEY = (Get-Content .env | Where-Object { $_ -match 'GOOGLE_KEY' } | ForEach-Object { ($_ -split '=')[1] })
$env:GOOGLE_TOKEN = (Get-Content .env | Where-Object { $_ -match 'GOOGLE_TOKEN' } | ForEach-Object { ($_ -split '=')[1] })

$token = Invoke-RestMethod -Uri "https://securetoken.googleapis.com/v1/token?key=$env:GOOGLE_KEY" -Method Post -Body "grant_type=refresh_token&refresh_token=$env:GOOGLE_TOKEN" -ContentType "application/x-www-form-urlencoded"
$profiles = Invoke-RestMethod -Uri "https://api.prod.boo.dating/v1/user/dailyProfiles" -Method Get -Headers @{Authorization = $token.access_token}

Write-Host "Found $($profiles.profiles.Count) profiles to like"

foreach ($profile in $profiles.profiles) {
    Write-Host "Liking $($profile.firstName)..."
    $response = Invoke-RestMethod -Uri "https://api.prod.boo.dating/v1/user/sendLike" -Method Patch -Body (ConvertTo-Json @{user = $profile._id}) -ContentType "application/json" -Headers @{Authorization = $token.access_token}
    Write-Host "Response: $response"
}