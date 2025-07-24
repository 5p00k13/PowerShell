#Function	                       Purpose
#Admin check	                       Ensures it runs safely with privileges
#Temp cache clear	               Frees space and removes junk
#Windows Update cache reset	       Fixes update issues
#DNS flush	                       Fixes some network issues
#Edge/IE cleanup	                       Clears browser leftovers
#Thumbnail/icon cache reset	       Fixes weird folder previews
#Prefetch clear	                       Refreshes app launch data




# Check for admin
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Warning "This script must be run as Administrator. Right-click PowerShell and choose 'Run as Administrator'."
    exit
}

Write-Host "`nClearing cache...`n"

# Temp folders
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Windows Update cache
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv

# DNS cache
Clear-DnsClientCache

# IE/Edge browser cache
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
$edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
if (Test-Path $edgeCache) {
    Remove-Item "$edgeCache\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# Thumbnail cache
ie4uinit.exe -ClearIconCache
Stop-Process -Name explorer -Force
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer.exe

# Prefetch
Remove-Item "C:\Windows\Prefetch\*" -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "`n✅ All major caches cleared."

