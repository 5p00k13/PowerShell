# Ensure script is running as admin
function Ensure-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Output "Restarting script as Administrator..."
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
}
Ensure-Admin  # Ensure we have admin rights

# Function to get installed programs from the registry
function Get-InstalledPrograms {
    $programs = @()
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $registryPaths) {
        $programs += Get-ItemProperty -Path $path | Select-Object DisplayName, UninstallString, PSChildName
    }

    return $programs
}

# Function to check if a program is still installed
function IsProgramInstalled($programName) {
    $installedPrograms = Get-InstalledPrograms
    return $installedPrograms | Where-Object { $_.DisplayName -eq $programName }
}

# Function to uninstall software with silent mode
function Uninstall-Software {
    param (
        [string]$UninstallString,
        [string]$AppName,
        [string]$ProductGUID
    )

    if (-not $UninstallString) {
        Write-Output "Uninstall string not found for $AppName"
        return
    }

    $ExePath = $null
    $SilentArgs = ""

    if ($UninstallString -match "msiexec\.exe") {
        # MSI Installer (Extract GUID)
        $GUID = $UninstallString -replace '.*({.*}).*', '$1'
        if ($GUID -match "^{.*}$") {
            Write-Output "Detected MSI uninstaller for $AppName. Using GUID: $GUID"
            $ExePath = "msiexec.exe"
            $SilentArgs = "/X $GUID /qn /norestart"
        }
    } elseif ($UninstallString -match "\.exe") {
        # EXE Installer (Try Silent Flags)
        $ExePath = ($UninstallString -split '\s')[0]  # Extract EXE path
        $SilentArgs = "/S /silent /quiet /norestart"  # Common silent flags
    }

    if ($ExePath -and (Test-Path $ExePath)) {
        Write-Output "Attempting to uninstall $AppName silently..."
        Start-Process -FilePath $ExePath -ArgumentList $SilentArgs -NoNewWindow -Wait
        Start-Sleep -Seconds 10
    } else {
        Write-Output "Uninstall command invalid for $AppName. Trying force removal (if applicable)..."
    }

    # If still installed, try force removal with GUID (MSI only)
    if (IsProgramInstalled $AppName) {
        if ($ProductGUID -match "^{.*}$") {
            Write-Output "Initial uninstall failed. Forcing removal using MSI GUID..."
            Start-Process "msiexec.exe" -ArgumentList "/X $ProductGUID /qn /norestart" -NoNewWindow -Wait
            Start-Sleep -Seconds 10
        } else {
            Write-Output "No MSI GUID found for $AppName. Manual removal may be required."
        }
    }

    # Final check
    if (IsProgramInstalled $AppName) {
        Write-Output "$AppName was NOT successfully removed."
    } else {
        Write-Output "$AppName has been successfully uninstalled."
    }
}

# Prompt for a name or keyword
$nameOrKeyword = Read-Host "Enter the name or keyword to search for"

# Get installed programs and filter by keyword
$installedPrograms = Get-InstalledPrograms
$filteredPrograms = $installedPrograms | Where-Object { $_.DisplayName -and $_.UninstallString -and $_.DisplayName -like "*$nameOrKeyword*" }

# Add a quit option (0)
$counter = 1
$programList = @([PSCustomObject]@{ Number = 0; DisplayName = "Quit"; UninstallString = ""; ProductGUID = "" }) + 
               ($filteredPrograms | ForEach-Object { 
                   [PSCustomObject]@{ Number = $counter++; DisplayName = $_.DisplayName; UninstallString = $_.UninstallString; ProductGUID = $_.PSChildName }
               })

# Display the filtered list with numbers
$programList | Format-Table -Property Number, DisplayName, UninstallString, ProductGUID -AutoSize

# Prompt for the numbers of the programs to remove
$programNumbers = Read-Host "Enter the numbers of the programs to remove, separated by commas (0 to Quit)"

# Convert input to an array of numbers
$programNumbersArray = $programNumbers -split "," | ForEach-Object { $_.Trim() -as [int] }

# Exit if the user selected 0
if (0 -in $programNumbersArray) {
    Write-Output "Exiting script."
    Exit
}

# Uninstall the selected programs
foreach ($number in $programNumbersArray) {
    $program = $programList | Where-Object { $_.Number -eq $number }
    if ($program -and $program.Number -ne 0) {
        Uninstall-Software -UninstallString $program.UninstallString -AppName $program.DisplayName -ProductGUID $program.ProductGUID
    } else {
        Write-Output "Invalid selection: $number"
    }
}
