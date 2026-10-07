# GradeGlow — authorize Google Sign-In for Flutter web (local + deploy).
# Run from project root: .\scripts\setup_web_auth.ps1

$ProjectId = "ai-studybuddy-1fad1"
$WebClientId = "118727197700-pvonsvqkegu0kuqcqmsqsh8ii2nj8opa.apps.googleusercontent.com"

Write-Host ""
Write-Host "GradeGlow web Google Sign-In setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1) Firebase Console — Authorized domains" -ForegroundColor Yellow
Write-Host "   https://console.firebase.google.com/project/$ProjectId/authentication/settings"
Write-Host "   Ensure these are listed under Authorized domains:"
Write-Host "     - localhost"
Write-Host "     - $ProjectId.firebaseapp.com"
Write-Host "     - gradeglow-virtualuni.web.app"
Write-Host "     - gradeglowuniversity.com"
Write-Host "     - www.gradeglowuniversity.com"
Write-Host ""
Write-Host "2) Google Cloud Console — OAuth JavaScript origins" -ForegroundColor Yellow
Write-Host "   https://console.cloud.google.com/apis/credentials?project=$ProjectId"
Write-Host "   Open OAuth 2.0 Client ID (Web client):"
Write-Host "     $WebClientId"
Write-Host "   Under Authorized JavaScript origins, add every URL you use, for example:"
Write-Host "     http://localhost"
Write-Host "     http://localhost:8080"
Write-Host "     http://localhost:5000"
Write-Host "     http://127.0.0.1"
Write-Host "     https://gradeglow-virtualuni.web.app"
Write-Host "     https://gradeglowuniversity.com"
Write-Host "     https://www.gradeglowuniversity.com"
Write-Host "   Under Authorized redirect URIs, also add:"
Write-Host "     https://$ProjectId.firebaseapp.com/__/auth/handler"
Write-Host "     https://gradeglow-virtualuni.web.app/__/auth/handler"
Write-Host "     https://gradeglowuniversity.com/__/auth/handler"
Write-Host "     https://www.gradeglowuniversity.com/__/auth/handler"
Write-Host ""
Write-Host "   Tip: check your browser address bar while the app runs — the port must match."
Write-Host "   Flutter web often uses http://localhost:XXXXX (note the exact port)."
Write-Host ""
Write-Host "3) Dynamic Links shutdown (email link / Cordova)" -ForegroundColor Yellow
Write-Host "   GradeGlow does not use passwordless email-link sign-in or Cordova OAuth."
Write-Host "   Run: .\scripts\fix_auth_email.ps1"
Write-Host "   That disables invalid .web.app email-domain setup and points templates at the live app."
Write-Host "   Branded sender later: Authentication -> Templates -> Customize domain -> gradeglowuniversity.com"
Write-Host ""
Write-Host "4) Rebuild and run web" -ForegroundColor Yellow
Write-Host "   flutter run -d chrome"
Write-Host "   or: flutter run -d web-server --web-port=8080"
Write-Host ""
