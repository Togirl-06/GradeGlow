# Deploy GradeGlow web to Firebase Hosting.
# Does NOT bake OPENAI_API_KEY into client JS.
# For web AI: enable Blaze billing, then this script deploys /api/openai Cloud Function
# using functions/.env (gitignored) copied from the project .env.

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location $projectRoot

Write-Host "GradeGlow: build web and deploy hosting" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter not found on PATH." -ForegroundColor Yellow
    exit 1
}
if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "Firebase CLI not found. Install firebase-tools and run firebase login." -ForegroundColor Yellow
    exit 1
}

function Get-DotEnvValue([string]$Key) {
    $envFile = Join-Path $projectRoot ".env"
    if (-not (Test-Path $envFile)) { return "" }
    foreach ($line in Get-Content $envFile) {
        if ($line -match "^\s*#" -or $line -notmatch "=") { continue }
        $parts = $line.Split("=", 2)
        if ($parts[0].Trim() -eq $Key) {
            return $parts[1].Trim().Trim('"').Trim("'")
        }
    }
    return ""
}

$openAiKey = Get-DotEnvValue "OPENAI_API_KEY"
$deployFunctions = $false
if ((Get-Command npm -ErrorAction SilentlyContinue) -and -not [string]::IsNullOrWhiteSpace($openAiKey)) {
    $fnEnv = Join-Path $projectRoot "functions\.env"
    Set-Content -Path $fnEnv -Value "OPENAI_API_KEY=$openAiKey" -Encoding ascii
    Push-Location (Join-Path $projectRoot "functions")
    npm install --no-fund --no-audit | Out-Null
    if ($LASTEXITCODE -eq 0) { $deployFunctions = $true }
    Pop-Location
}

# Web release must not embed .env secrets. Local debug can still use flutter_dotenv.
flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($deployFunctions) {
    Write-Host "Deploying hosting + openaiProxy function..." -ForegroundColor Cyan
    firebase deploy --only functions:openaiProxy,hosting:gradeglow --project ai-studybuddy-1fad1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Functions deploy failed (enable Blaze billing for /api/openai). Deploying hosting only..." -ForegroundColor Yellow
        firebase deploy --only hosting:gradeglow --project ai-studybuddy-1fad1
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
} else {
    firebase deploy --only hosting:gradeglow --project ai-studybuddy-1fad1
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host ""
Write-Host "GradeGlow: https://gradeglow-virtualuni.web.app" -ForegroundColor Green
Write-Host "Web AI needs Blaze + openaiProxy. Enable billing, then rerun this script."
Write-Host "Custom domain when Connected: https://gradeglowuniversity.com"
