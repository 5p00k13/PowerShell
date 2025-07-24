# Define log file path
$LogFile = "C:\Temp\UninstallLog.txt"

# Ensure C:\Temp exists
if (!(Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
}

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$Timestamp - $Message"
}

# Function to uninstall software using MsiExec
function Uninstall-Software {
    param (
        [string]$GUID,
        [string]$AppName
    )

    if ($GUID) {
        Write-Log "Uninstalling: $AppName"
        Start-Process "msiexec.exe" -ArgumentList "/X $GUID /qn /norestart" -WindowStyle Hidden -Wait
        Write-Log "Uninstall completed: $AppName"
    } else {
        Write-Log "Uninstall GUID not found for: $AppName"
    }
}

# Uninstall in the correct order, running the process twice
for ($i=1; $i -le 2; $i++) {
    Write-Log "Starting uninstall cycle $i"

    # 1. HP Wolf Security
    Uninstall-Software "{3E8B9FC0-E009-11EF-8765-000C29910851}" "HP Wolf Security"

    # 2. HP Wolf Security - Console
    Uninstall-Software "{2086BEEB-1F4B-4A5C-9FDE-DABD8960E2C7}" "HP Wolf Security - Console"

    # 3. HP Security Update Service
    Uninstall-Software "{EA79B146-BCB3-4053-B48F-B3F2D1469304}" "HP Security Update Service"

    Write-Log "Uninstall cycle $i completed"
}
 