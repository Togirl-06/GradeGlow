# Deploy the GradeGlow website to Firebase Hosting.
# Requires: Flutter SDK, npm install -g firebase-tools, firebase login

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location $projectRoot

Write-Host "GradeGlow — build web and deploy hosting" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter not found on PATH." -ForegroundColor Yellow
    exit 1
}
if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "Firebase CLI not found. Install it:" -ForegroundColor Yellow
    Write-Host "  npm install -g firebase-tools"
    Write-Host "  firebase login"
    exit 1
}

flutter build web --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

firebase deploy --only hosting --project ai-studybuddy-1fad1
Write-Host ""
Write-Host "Site: https://ai-studybuddy-1fad1.web.app" -ForegroundColor Green
