# Prompt the user for the program name
$programName = Read-Host "Enter the program name"

# Function to get uninstall strings from a registry path
function Get-UninstallStrings {
    param (
        [string]$registryPath
    )
    Get-ChildItem $registryPath -ErrorAction SilentlyContinue | ForEach-Object {
        $displayName = $_.GetValue("DisplayName")
        $uninstallString = $_.GetValue("UninstallString")
        if ($displayName -like "*$programName*") {
            [PSCustomObject]@{
                Name = $displayName
                UninstallString = $uninstallString
            }
        }
    } | Where-Object { $_ -ne $null }
}

# Get uninstall strings from both 64-bit and 32-bit registry paths
$uninstallStrings64 = Get-UninstallStrings -registryPath "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$uninstallStrings32 = Get-UninstallStrings -registryPath "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

# Combine the results
$matchingPrograms = $uninstallStrings64 + $uninstallStrings32

if ($matchingPrograms) {
    $matchingPrograms | Format-Table -AutoSize
} else {
    Write-Host "No programs found with the name '$programName'."
}