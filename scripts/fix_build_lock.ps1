# Run from project root when Gradle fails to delete build\ folders (OneDrive / file locks).
$ErrorActionPreference = "SilentlyContinue"

Write-Host "Stopping Gradle daemons..."
if (Test-Path "android\gradlew.bat") {
    Push-Location android
    & .\gradlew.bat --stop
    Pop-Location
}

Get-Process -Name "java", "dart" -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep -Seconds 2

Write-Host "Removing build folders..."
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ".dart_tool" -ErrorAction SilentlyContinue

Write-Host "Done. Run: flutter pub get && flutter run"
