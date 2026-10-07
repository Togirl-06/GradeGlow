# Point Firebase Auth mobile / out-of-band email links at Hosting instead of
# Firebase Dynamic Links (shut down). Wrapper for fix_auth_email.ps1.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $scriptDir "fix_auth_email.ps1") @args