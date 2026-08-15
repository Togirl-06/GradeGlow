# Deploy Firestore security rules for GradeGlow.
# Requires: npm install -g firebase-tools  &&  firebase login

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent

Write-Host "GradeGlow — deploy Firestore rules" -ForegroundColor Cyan
Write-Host "Project: ai-studybuddy-1fad1" -ForegroundColor DarkGray
Write-Host ""

Set-Location $projectRoot

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "Firebase CLI not found. Install it:" -ForegroundColor Yellow
    Write-Host "  npm install -g firebase-tools"
    Write-Host "  firebase login"
    Write-Host ""
    Write-Host "Or paste firestore.rules manually in Firebase Console:" -ForegroundColor Yellow
    Write-Host "  Firestore Database -> Rules -> Publish"
    exit 1
}

firebase deploy --only firestore:rules,storage --project ai-studybuddy-1fad1
Write-Host ""
Write-Host "Done. Restart the app and sign in again." -ForegroundColor Green
