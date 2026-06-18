# Prints SHA-1 / SHA-256 for Firebase Google Sign-In (debug keystore).
$keystore = "$env:USERPROFILE\.android\debug.keystore"
$keytool = "$env:ProgramFiles\Android\Android Studio\jbr\bin\keytool.exe"

if (-not (Test-Path $keystore)) {
    Write-Host "Debug keystore not found: $keystore"
    exit 1
}
if (-not (Test-Path $keytool)) {
    Write-Host "keytool not found. Open Android Studio or set JAVA_HOME."
    exit 1
}

Write-Host "Add these fingerprints in Firebase Console:"
Write-Host "  Project Settings -> Your apps -> Android app -> Add fingerprint"
Write-Host ""
& $keytool -list -v -keystore $keystore -alias androiddebugkey -storepass android -keypass android |
    Select-String "SHA1:|SHA256:"
