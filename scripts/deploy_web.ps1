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
$stripeSecret = Get-DotEnvValue "STRIPE_SECRET_KEY"
$stripeWebhook = Get-DotEnvValue "STRIPE_WEBHOOK_SECRET"
# Prefer keys already in functions/.env when root .env omits them.
$fnEnvPath = Join-Path $projectRoot "functions\.env"
function Get-FnEnvValue([string]$Key) {
    if (-not (Test-Path $fnEnvPath)) { return "" }
    foreach ($line in Get-Content $fnEnvPath) {
        if ($line -match "^\s*#" -or $line -notmatch "=") { continue }
        $parts = $line.Split("=", 2)
        if ($parts[0].Trim() -eq $Key) {
            return $parts[1].Trim().Trim('"').Trim("'")
        }
    }
    return ""
}
if ([string]::IsNullOrWhiteSpace($stripeSecret)) { $stripeSecret = Get-FnEnvValue "STRIPE_SECRET_KEY" }
if ([string]::IsNullOrWhiteSpace($stripeWebhook)) { $stripeWebhook = Get-FnEnvValue "STRIPE_WEBHOOK_SECRET" }
if ([string]::IsNullOrWhiteSpace($openAiKey)) { $openAiKey = Get-FnEnvValue "OPENAI_API_KEY" }

$deployFunctions = $false
if ((Get-Command npm -ErrorAction SilentlyContinue) -and -not [string]::IsNullOrWhiteSpace($openAiKey)) {
    $envLines = @("OPENAI_API_KEY=$openAiKey")
    if (-not [string]::IsNullOrWhiteSpace($stripeSecret)) {
        $envLines += "STRIPE_SECRET_KEY=$stripeSecret"
    }
    if (-not [string]::IsNullOrWhiteSpace($stripeWebhook)) {
        $envLines += "STRIPE_WEBHOOK_SECRET=$stripeWebhook"
    }
    Set-Content -Path $fnEnvPath -Value ($envLines -join "`n") -Encoding ascii
    Push-Location (Join-Path $projectRoot "functions")
    npm install --no-fund --no-audit | Out-Null
    if ($LASTEXITCODE -eq 0) { $deployFunctions = $true }
    Pop-Location
}

# Web release must not embed .env secrets. Local debug can still use flutter_dotenv.
flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($deployFunctions) {
    Write-Host "Deploying hosting + Cloud Functions (OpenAI + Stripe)..." -ForegroundColor Cyan
    $env:FUNCTIONS_DISCOVERY_TIMEOUT = "120"
    $fnTargets = "functions:openaiProxy,functions:createStripeCheckout,functions:confirmStripeCheckout,functions:stripeWebhook,hosting:gradeglow"
    firebase deploy --only $fnTargets --project ai-studybuddy-1fad1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Functions deploy failed (enable Blaze billing). Deploying hosting only..." -ForegroundColor Yellow
        firebase deploy --only hosting:gradeglow --project ai-studybuddy-1fad1
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
} else {
    firebase deploy --only hosting:gradeglow --project ai-studybuddy-1fad1
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host ""
Write-Host "GradeGlow: https://gradeglow-virtualuni.web.app" -ForegroundColor Green
if ([string]::IsNullOrWhiteSpace($stripeSecret)) {
    Write-Host "Stripe: add STRIPE_SECRET_KEY (+ STRIPE_WEBHOOK_SECRET) to .env or functions/.env, then redeploy." -ForegroundColor Yellow
} else {
    Write-Host "Stripe checkout API deployed. Webhook: https://us-central1-ai-studybuddy-1fad1.cloudfunctions.net/stripeWebhook" -ForegroundColor Green
}
Write-Host "Custom domain when Connected: https://gradeglowuniversity.com"
