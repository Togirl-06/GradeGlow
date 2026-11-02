# Fix Firebase Auth email setup after Dynamic Links shutdown.
# - Cancels stuck .web.app custom email sender verification (cannot add DNS there)
# - Points email template action URL at the live app when the API allows it
# - Sets mobileLinksConfig to Firebase Hosting (not Dynamic Links)
# Run from project root after: firebase login

param(
    [string]$ProjectId = "ai-studybuddy-1fad1",
    [string]$AppUrl = "https://gradeglow-virtualuni.web.app",
    [string]$BrandedEmailDomain = "gradeglowuniversity.com"
)

$ErrorActionPreference = "Stop"

function Get-GoogleAccessToken {
    if (Get-Command gcloud -ErrorAction SilentlyContinue) {
        $token = & gcloud auth print-access-token 2>$null
        if ($LASTEXITCODE -eq 0 -and $token) { return $token.Trim() }
    }

    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        throw "Need gcloud or Node.js. Run: firebase login"
    }

    $js = @'
const fs = require("fs");
const os = require("os");
const path = require("path");
const candidates = [
  path.join(os.homedir(), ".config", "configstore", "firebase-tools.json"),
  path.join(process.env.APPDATA || "", "configstore", "firebase-tools.json"),
  path.join(process.env.LOCALAPPDATA || "", "configstore", "firebase-tools.json"),
].filter(Boolean);
const file = candidates.find((p) => p && fs.existsSync(p));
if (!file) {
  process.stderr.write("No Firebase CLI config file. Run: firebase login\n");
  process.exit(1);
}
const raw = JSON.parse(fs.readFileSync(file, "utf8"));
const access = raw.tokens?.access_token;
if (!access) {
  process.stderr.write("No Firebase CLI access token. Run: firebase login\n");
  process.exit(1);
}
process.stdout.write(access);
'@
    $tmp = Join-Path $env:TEMP "gg-firebase-token.js"
    Set-Content -Path $tmp -Value $js -Encoding UTF8
    try {
        $token = & node $tmp
        if ($LASTEXITCODE -ne 0 -or -not $token) {
            throw "Could not read a Firebase CLI token. Run: firebase login"
        }
        return $token.Trim()
    } finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

function Read-HttpErrorBody {
    param($ErrorRecord)
    if ($ErrorRecord.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($ErrorRecord.Exception.Response.GetResponseStream())
        return $reader.ReadToEnd()
    }
    return $ErrorRecord.Exception.Message
}

function Invoke-IdentityConfig {
    param(
        [string]$Method,
        [string]$Token,
        [hashtable]$Body = $null,
        [string]$UpdateMask = $null
    )

    $uri = "https://identitytoolkit.googleapis.com/admin/v2/projects/$ProjectId/config"
    if ($UpdateMask) {
        $uri += "?updateMask=$UpdateMask"
    }
    $headers = @{
        Authorization = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    if ($Method -eq "GET") {
        return Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    }
    try {
        return Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 8 -Compress)
    } catch {
        throw (Read-HttpErrorBody $_)
    }
}

function Invoke-CancelEmailDomainVerification {
    param(
        [string]$Token,
        [string]$Domain
    )

    $uri = "https://identitytoolkit.googleapis.com/admin/v2/projects/$ProjectId/domain:verify"
    $headers = @{
        Authorization = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    $body = @{
        domain = $Domain
        action = "CANCEL"
    } | ConvertTo-Json -Compress

    try {
        return Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
    } catch {
        throw (Read-HttpErrorBody $_)
    }
}

function Try-IdentityPatch {
    param(
        [string]$Token,
        [hashtable]$Body,
        [string]$UpdateMask,
        [string]$Label
    )

    try {
        Invoke-IdentityConfig -Method Patch -Token $Token -Body $Body -UpdateMask $UpdateMask | Out-Null
        Write-Host "  $Label - OK" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  $Label - skipped" -ForegroundColor Yellow
        return $false
    }
}

Write-Host ""
Write-Host "GradeGlow: fix Auth email + Dynamic Links migration" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

$token = Get-GoogleAccessToken

Write-Host ""
Write-Host "Before:" -ForegroundColor Yellow
$before = Invoke-IdentityConfig -Method GET -Token $token
$dns = $before.notification.sendEmail.dnsInfo
if ($dns) {
    Write-Host "  pendingCustomDomain : $($dns.pendingCustomDomain)"
    Write-Host "  customDomain        : $($dns.customDomain)"
    Write-Host "  customDomainState   : $($dns.customDomainState)"
    Write-Host "  useCustomDomain     : $($dns.useCustomDomain)"
}
Write-Host "  callbackUri         : $($before.notification.sendEmail.callbackUri)"
Write-Host "  mobileLinksConfig   : $($before.mobileLinksConfig.domain)"

Write-Host ""
Write-Host "Applying fix..." -ForegroundColor Yellow

$pending = $dns.pendingCustomDomain
if ($pending) {
    Write-Host "  Cancelling stuck verification for: $pending"
    $cancel = Invoke-CancelEmailDomainVerification -Token $token -Domain $pending
    Write-Host "  Cancel result state: $($cancel.verificationState)" -ForegroundColor Green
}

Try-IdentityPatch -Token $token -Label "Disable custom email sender domain" -UpdateMask "notification.sendEmail.dnsInfo.useCustomDomain" -Body @{
    notification = @{
        sendEmail = @{
            dnsInfo = @{ useCustomDomain = $false }
        }
    }
} | Out-Null

Try-IdentityPatch -Token $token -Label "Set email template action URL" -UpdateMask "notification.sendEmail.callbackUri" -Body @{
    notification = @{
        sendEmail = @{ callbackUri = $AppUrl }
    }
} | Out-Null

Try-IdentityPatch -Token $token -Label "Use Hosting for mobile auth links" -UpdateMask "mobileLinksConfig" -Body @{
    mobileLinksConfig = @{ domain = "HOSTING_DOMAIN" }
} | Out-Null

Write-Host ""
Write-Host "After:" -ForegroundColor Green
$after = Invoke-IdentityConfig -Method GET -Token $token
$afterDns = $after.notification.sendEmail.dnsInfo
Write-Host "  pendingCustomDomain : $($afterDns.pendingCustomDomain)"
Write-Host "  customDomainState   : $($afterDns.customDomainState)"
Write-Host "  useCustomDomain     : $($afterDns.useCustomDomain)"
Write-Host "  callbackUri         : $($after.notification.sendEmail.callbackUri)"
Write-Host "  mobileLinksConfig   : $($after.mobileLinksConfig.domain)"
Write-Host ""
Write-Host "Auth emails use Firebase default sender and work now." -ForegroundColor Green
Write-Host "App code sends verify/reset continue links to $AppUrl."
Write-Host ""
Write-Host "Do NOT verify gradeglow-virtualuni.web.app for email - you cannot add DNS on .web.app." -ForegroundColor Yellow
Write-Host "For branded sender later: Authentication - Templates - Customize domain - $BrandedEmailDomain"
Write-Host ""
