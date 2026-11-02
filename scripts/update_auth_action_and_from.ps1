# Change Auth email Action URL (%LINK%) and prepare branded From.
# Action URL -> live Hosting site (not ai-studybuddy-1fad1.firebaseapp.com).
# From domain cannot be .web.app; start verification for gradeglowuniversity.com.
# Run from project root after: firebase login

param(
    [string]$ProjectId = "ai-studybuddy-1fad1",
    [string]$ActionUrl = "https://gradeglow-virtualuni.web.app/__/auth/action",
    [string]$AuthorizedHost = "gradeglow-virtualuni.web.app",
    [string]$FromDomain = "gradeglowuniversity.com"
)

$ErrorActionPreference = "Stop"

function Get-GoogleAccessToken {
    if (Get-Command gcloud -ErrorAction SilentlyContinue) {
        $token = & gcloud auth print-access-token 2>$null
        if ($LASTEXITCODE -eq 0 -and $token) { return $token.Trim() }
    }
    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) { throw "Need Node.js. Run: firebase login" }

    $js = @'
const fs = require("fs");
const os = require("os");
const path = require("path");
const candidates = [
  path.join(os.homedir(), ".config", "configstore", "firebase-tools.json"),
  path.join(process.env.APPDATA || "", "configstore", "firebase-tools.json"),
].filter(Boolean);
const file = candidates.find((p) => p && fs.existsSync(p));
if (!file) { process.stderr.write("Run: firebase login\n"); process.exit(1); }
const access = JSON.parse(fs.readFileSync(file, "utf8")).tokens?.access_token;
if (!access) { process.stderr.write("Run: firebase login\n"); process.exit(1); }
process.stdout.write(access);
'@
    $tmp = Join-Path $env:TEMP "gg-firebase-token.js"
    Set-Content -Path $tmp -Value $js -Encoding UTF8
    try {
        $token = & node $tmp
        if ($LASTEXITCODE -ne 0 -or -not $token) { throw "Run: firebase login" }
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

$token = Get-GoogleAccessToken
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}
$configUri = "https://identitytoolkit.googleapis.com/admin/v2/projects/$ProjectId/config"

Write-Host ""
Write-Host "GradeGlow: Action URL + From" -ForegroundColor Cyan
$cfg = Invoke-RestMethod -Method Get -Uri $configUri -Headers $headers
Write-Host "  callbackUri now : $($cfg.notification.sendEmail.callbackUri)"
Write-Host "  authorized      : $($cfg.authorizedDomains -join ', ')"
Write-Host "  from custom     : $($cfg.notification.sendEmail.dnsInfo.customDomain) / $($cfg.notification.sendEmail.dnsInfo.pendingCustomDomain) / $($cfg.notification.sendEmail.dnsInfo.customDomainState)"

$domains = @()
if ($cfg.authorizedDomains) { $domains = @($cfg.authorizedDomains) }
$needed = @($AuthorizedHost, $FromDomain, "www.$FromDomain")
$added = @()
foreach ($d in $needed) {
    if ($domains -notcontains $d) {
        $domains += $d
        $added += $d
    }
}
if ($added.Count -gt 0) {
    $body = @{ authorizedDomains = $domains } | ConvertTo-Json -Compress
    $uri = "$configUri`?updateMask=authorizedDomains"
    try {
        Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -Body $body | Out-Null
        Write-Host "  Authorized domains added: $($added -join ', ')" -ForegroundColor Green
    } catch {
        Write-Host "  Authorized domains skipped: $(Read-HttpErrorBody $_)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Authorized domains already include $AuthorizedHost"
}

$actionBody = '{"notification":{"sendEmail":{"callbackUri":"' + $ActionUrl + '"}}}'
$actionUri = "$configUri`?updateMask=notification.sendEmail.callbackUri"
try {
    $updated = Invoke-RestMethod -Method Patch -Uri $actionUri -Headers $headers -Body $actionBody
    Write-Host "  Action URL -> $($updated.notification.sendEmail.callbackUri)" -ForegroundColor Green
} catch {
    Write-Host "  Action URL API blocked. Set this in Console:" -ForegroundColor Yellow
    Write-Host "    $ActionUrl"
    Write-Host "    $(Read-HttpErrorBody $_)"
}

$verifyUri = "https://identitytoolkit.googleapis.com/admin/v2/projects/$ProjectId/domain:verify"
$verifyBody = @{ domain = $FromDomain; action = "VERIFY" } | ConvertTo-Json -Compress
try {
    $verify = Invoke-RestMethod -Method Post -Uri $verifyUri -Headers $headers -Body $verifyBody
    Write-Host "  From-domain verify: $($verify.verificationState) for $FromDomain" -ForegroundColor Green
    if ($verify.verificationError) { Write-Host "    $($verify.verificationError)" }
} catch {
    Write-Host "  From-domain verify: $(Read-HttpErrorBody $_)" -ForegroundColor Yellow
}

$after = Invoke-RestMethod -Method Get -Uri $configUri -Headers $headers
$dns = $after.notification.sendEmail.dnsInfo
Write-Host ""
Write-Host "After:" -ForegroundColor Green
Write-Host "  callbackUri         : $($after.notification.sendEmail.callbackUri)"
Write-Host "  pendingCustomDomain : $($dns.pendingCustomDomain)"
Write-Host "  customDomainState   : $($dns.customDomainState)"
Write-Host ""
Write-Host "Console values if the field is still grey:"
Write-Host "  Action URL: $ActionUrl"
Write-Host "  From     : noreply@$FromDomain  (after DNS for $FromDomain is verified)"
Write-Host "  Do not use noreply@$AuthorizedHost - you cannot add DNS on .web.app"
Write-Host ""
