# Connect gradeglowuniversity.com to Firebase Hosting.
# Open this script after you buy the domain. It prints the exact clicks.
# DNS records must be copied from the Firebase Console — they are unique per site.

$ProjectId = "ai-studybuddy-1fad1"
$Domain = "gradeglowuniversity.com"

Write-Host ""
Write-Host "GradeGlow custom domain: $Domain" -ForegroundColor Cyan
Write-Host ""
Write-Host "A) Add the domain in Firebase (you only do this once)" -ForegroundColor Yellow
Write-Host "   1. Open:"
Write-Host "      https://console.firebase.google.com/project/$ProjectId/hosting/sites/gradeglow-virtualuni"
Write-Host "   2. Click Custom domain → Add custom domain"
Write-Host "   3. Enter: $Domain"
Write-Host "   4. Also add: www.$Domain  and choose Redirect to $Domain"
Write-Host "   5. Copy EVERY DNS record Firebase shows (TXT, A, AAAA, CNAME)."
Write-Host "      Do not guess IP addresses. Use the values on that screen."
Write-Host ""
Write-Host "B) Paste those records at your registrar (Porkbun, Cloudflare, GoDaddy, Namecheap, Google Domains)" -ForegroundColor Yellow
Write-Host "   Typical shape (values come from Firebase):"
Write-Host "      A      @     <Firebase IPv4 from the console>"
Write-Host "      A      @     <second Firebase IPv4 if shown>"
Write-Host "      AAAA   @     <Firebase IPv6 if shown>"
Write-Host "      CNAME  www   $Domain   or the target Firebase prints"
Write-Host "      TXT    @     hosting-site=gradeglow-virtualuni   (if asked)"
Write-Host "   If you use Cloudflare, set the orange cloud to DNS-only (grey) until SSL is Connected."
Write-Host ""
Write-Host "C) Allow Google sign-in on the new name" -ForegroundColor Yellow
Write-Host "   Authorized domains:"
Write-Host "      https://console.firebase.google.com/project/$ProjectId/authentication/settings"
Write-Host "      Add: $Domain"
Write-Host "      Add: www.$Domain"
Write-Host "   Then run:"
Write-Host "      .\scripts\setup_web_auth.ps1"
Write-Host ""
Write-Host "D) Wait" -ForegroundColor Yellow
Write-Host "   SSL often takes 15 minutes to a few hours. Status in Hosting goes Needs setup → Pending → Connected."
Write-Host "   When it is Connected, open https://$Domain"
Write-Host ""
Write-Host "Backup while DNS is pending: https://gradeglow-virtualuni.web.app"
Write-Host ""
