# Writes Stripe keys into .env + functions/.env and redeploys Stripe Cloud Functions.
# Usage: .\scripts\configure_stripe.ps1
# Get keys from https://dashboard.stripe.com/apikeys and Webhooks.

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location $projectRoot

Write-Host "GradeGlow Stripe setup" -ForegroundColor Cyan
Write-Host "Paste your Stripe Secret Key (sk_live_... or sk_test_...). Input is hidden."
$sec = Read-Host -AsSecureString "STRIPE_SECRET_KEY"
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
try {
    $stripeSecret = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}
if ([string]::IsNullOrWhiteSpace($stripeSecret) -or $stripeSecret -notmatch '^sk_') {
    Write-Host "Invalid secret key (expected sk_live_... or sk_test_...)." -ForegroundColor Red
    exit 1
}

Write-Host "Optional: paste Webhook signing secret (whsec_...). Leave blank to skip."
$whSec = Read-Host -AsSecureString "STRIPE_WEBHOOK_SECRET"
$wbstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($whSec)
try {
    $stripeWebhook = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($wbstr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($wbstr)
}

function Upsert-EnvLine([string]$Path, [string]$Key, [string]$Value) {
    $lines = @()
    if (Test-Path $Path) {
        $lines = Get-Content $Path
    }
    $found = $false
    $out = foreach ($line in $lines) {
        if ($line -match "^\s*#" -or $line -notmatch "=") { $line; continue }
        $parts = $line.Split("=", 2)
        if ($parts[0].Trim() -eq $Key) {
            $found = $true
            "$Key=$Value"
        } else {
            $line
        }
    }
    if (-not $found) { $out = @($out) + "$Key=$Value" }
    Set-Content -Path $Path -Value $out -Encoding ascii
}

$rootEnv = Join-Path $projectRoot ".env"
$fnEnv = Join-Path $projectRoot "functions\.env"
Upsert-EnvLine $rootEnv "STRIPE_SECRET_KEY" $stripeSecret
Upsert-EnvLine $fnEnv "STRIPE_SECRET_KEY" $stripeSecret
if (-not [string]::IsNullOrWhiteSpace($stripeWebhook) -and $stripeWebhook -match '^whsec_') {
    Upsert-EnvLine $rootEnv "STRIPE_WEBHOOK_SECRET" $stripeWebhook
    Upsert-EnvLine $fnEnv "STRIPE_WEBHOOK_SECRET" $stripeWebhook
}

# Keep OPENAI key if present
function Get-EnvValue([string]$Path, [string]$Key) {
    if (-not (Test-Path $Path)) { return "" }
    foreach ($line in Get-Content $Path) {
        if ($line -match "^\s*#" -or $line -notmatch "=") { continue }
        $parts = $line.Split("=", 2)
        if ($parts[0].Trim() -eq $Key) { return $parts[1].Trim().Trim('"').Trim("'") }
    }
    return ""
}
$openAi = Get-EnvValue $rootEnv "OPENAI_API_KEY"
if ([string]::IsNullOrWhiteSpace($openAi)) { $openAi = Get-EnvValue $fnEnv "OPENAI_API_KEY" }
if (-not [string]::IsNullOrWhiteSpace($openAi)) {
    Upsert-EnvLine $fnEnv "OPENAI_API_KEY" $openAi
}

Write-Host "Keys saved. Deploying Stripe functions..." -ForegroundColor Cyan
Push-Location (Join-Path $projectRoot "functions")
npm install --no-fund --no-audit | Out-Null
Pop-Location

# Windows discovery often exceeds the default 10s load timeout.
$env:FUNCTIONS_DISCOVERY_TIMEOUT = "120"
firebase deploy --only functions:createStripeCheckout,functions:confirmStripeCheckout,functions:stripeWebhook --project ai-studybuddy-1fad1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Webhook URL (add in Stripe Dashboard → Developers → Webhooks):"
Write-Host "  https://us-central1-ai-studybuddy-1fad1.cloudfunctions.net/stripeWebhook"
Write-Host "Events: checkout.session.completed, customer.subscription.deleted"
Write-Host "Checkout also unlocks on return via confirmStripeCheckout (needs secret key only)."
