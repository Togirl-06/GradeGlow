# Push GradeGlow-branded Firebase Authentication email templates.
# Run from project root after: firebase login
# Source of truth: scripts/auth_email_templates.json

param(
    [string]$ProjectId = "ai-studybuddy-1fad1",
    [string]$TemplatesFile = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($TemplatesFile)) {
    $TemplatesFile = Join-Path $scriptDir "auth_email_templates.json"
}

function Get-GoogleAccessToken {
    if (Get-Command gcloud -ErrorAction SilentlyContinue) {
        $token = & gcloud auth print-access-token 2>$null
        if ($LASTEXITCODE -eq 0 -and $token) { return $token.Trim() }
    }

    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) { throw "Need gcloud or Node.js. Run: firebase login" }

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

function New-TemplatePayload {
    param($Source, $Shared)

    return @{
        senderDisplayName = $Shared.senderDisplayName
        senderLocalPart   = $Shared.senderLocalPart
        replyTo           = $Shared.replyTo
        subject           = $Source.subject
        body              = $Source.body
        bodyFormat        = "PLAIN_TEXT"
    }
}

if (-not (Test-Path $TemplatesFile)) {
    throw "Missing templates file: $TemplatesFile"
}

$shared = Get-Content $TemplatesFile -Raw | ConvertFrom-Json
$token = Get-GoogleAccessToken

$sendEmail = @{
    callbackUri = $shared.callbackUri
    verifyEmailTemplate = New-TemplatePayload $shared.verifyEmailTemplate $shared
    resetPasswordTemplate = New-TemplatePayload $shared.resetPasswordTemplate $shared
    changeEmailTemplate = New-TemplatePayload $shared.changeEmailTemplate $shared
    revertSecondFactorAdditionTemplate = New-TemplatePayload $shared.revertSecondFactorAdditionTemplate $shared
}

$patch = @{ notification = @{ sendEmail = $sendEmail } }

$mask = @(
    "notification.sendEmail.callbackUri",
    "notification.sendEmail.verifyEmailTemplate",
    "notification.sendEmail.resetPasswordTemplate",
    "notification.sendEmail.changeEmailTemplate",
    "notification.sendEmail.revertSecondFactorAdditionTemplate"
) -join ","

$uri = "https://identitytoolkit.googleapis.com/admin/v2/projects/$ProjectId/config?updateMask=$mask"
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}
$json = node -e "const fs=require('fs'); const t=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); const tpl=(s,x)=>({senderDisplayName:x.senderDisplayName,senderLocalPart:x.senderLocalPart,replyTo:x.replyTo,subject:s.subject,body:s.body,bodyFormat:'PLAIN_TEXT'}); const body={notification:{sendEmail:{callbackUri:t.callbackUri,verifyEmailTemplate:tpl(t.verifyEmailTemplate,t),resetPasswordTemplate:tpl(t.resetPasswordTemplate,t),changeEmailTemplate:tpl(t.changeEmailTemplate,t),revertSecondFactorAdditionTemplate:tpl(t.revertSecondFactorAdditionTemplate,t)}}}; process.stdout.write(JSON.stringify(body));" $TemplatesFile

Write-Host ""
Write-Host "GradeGlow: updating Auth email templates" -ForegroundColor Cyan
Write-Host "  verify subject : $($shared.verifyEmailTemplate.subject)"
Write-Host "  reset subject  : $($shared.resetPasswordTemplate.subject)"
Write-Host "  callbackUri    : $($shared.callbackUri)"
Write-Host ""

try {
    $result = Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -Body $json
} catch {
    $err = Read-HttpErrorBody $_
    if ($err -notmatch "EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED") {
        throw $err
    }

    Write-Host "Firebase blocked template body edits on this plan. Updating sender + project name instead." -ForegroundColor Yellow

    $senderJson = node -e "const fs=require('fs'); const t=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); const s={senderDisplayName:t.senderDisplayName,senderLocalPart:t.senderLocalPart,replyTo:t.replyTo}; const body={notification:{sendEmail:{verifyEmailTemplate:s,resetPasswordTemplate:s,changeEmailTemplate:s,revertSecondFactorAdditionTemplate:s}}}; process.stdout.write(JSON.stringify(body));" $TemplatesFile
    $senderMask = @(
        "notification.sendEmail.verifyEmailTemplate.senderDisplayName",
        "notification.sendEmail.verifyEmailTemplate.senderLocalPart",
        "notification.sendEmail.verifyEmailTemplate.replyTo",
        "notification.sendEmail.resetPasswordTemplate.senderDisplayName",
        "notification.sendEmail.resetPasswordTemplate.senderLocalPart",
        "notification.sendEmail.resetPasswordTemplate.replyTo",
        "notification.sendEmail.changeEmailTemplate.senderDisplayName",
        "notification.sendEmail.changeEmailTemplate.senderLocalPart",
        "notification.sendEmail.changeEmailTemplate.replyTo",
        "notification.sendEmail.revertSecondFactorAdditionTemplate.senderDisplayName",
        "notification.sendEmail.revertSecondFactorAdditionTemplate.senderLocalPart",
        "notification.sendEmail.revertSecondFactorAdditionTemplate.replyTo"
    ) -join ","
    $senderUri = "https://identitytoolkit.googleapis.com/admin/v2/projects/$ProjectId/config?updateMask=$senderMask"
    try {
        Invoke-RestMethod -Method Patch -Uri $senderUri -Headers $headers -Body $senderJson | Out-Null
        Write-Host "  Sender name / From / Reply-to updated." -ForegroundColor Green
    } catch {
        Write-Host "  Sender fields skipped: $(Read-HttpErrorBody $_)" -ForegroundColor Yellow
    }

    $nameUri = "https://cloudresourcemanager.googleapis.com/v1/projects/$ProjectId?updateMask=name"
    $nameBody = '{"name":"GradeGlow"}'
    try {
        $proj = Invoke-RestMethod -Method Patch -Uri $nameUri -Headers $headers -Body $nameBody
        Write-Host "  Google Cloud project name -> $($proj.name)  (%APP_NAME% in emails)" -ForegroundColor Green
    } catch {
        Write-Host "  Project display name skipped: $(Read-HttpErrorBody $_)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Paste these in Console -> Authentication -> Templates (pencil icon):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Email address verification"
    Write-Host "  Subject: $($shared.verifyEmailTemplate.subject)"
    Write-Host "  Body:"
    Write-Host $shared.verifyEmailTemplate.body
    Write-Host ""
    Write-Host "Password reset"
    Write-Host "  Subject: $($shared.resetPasswordTemplate.subject)"
    Write-Host "  Body:"
    Write-Host $shared.resetPasswordTemplate.body
    Write-Host ""
    Write-Host "Email address change"
    Write-Host "  Subject: $($shared.changeEmailTemplate.subject)"
    Write-Host "  Body:"
    Write-Host $shared.changeEmailTemplate.body
    Write-Host ""
    return
}

Write-Host "Updated templates in Firebase Console:" -ForegroundColor Green
Write-Host "  verify customized   : $($result.notification.sendEmail.verifyEmailTemplate.customized)"
Write-Host "  reset customized    : $($result.notification.sendEmail.resetPasswordTemplate.customized)"
Write-Host "  callbackUri         : $($result.notification.sendEmail.callbackUri)"
Write-Host ""
Write-Host "Preview: Authentication -> Templates in Firebase Console"
Write-Host ""
