# Define path to Uninstall.exe
$uninstallExePath = "C:\Program Files\Qualys\QualysAgent\uninstall.exe"

# Ensure the paths are correct before running
if (Test-Path $uninstallExePath) {
    Write-Host "Starting uninstall process for Qualys Cloud Security Agent..."

    # Run the uninstall command with Force=True to remove registry entries
    $uninstallCommand = "`"$uninstallExePath`" Uninstall=True Force=True"

    # Close any Explorer windows pointing to Qualys folders
    $qualysPaths = @("C:\Program Files\Qualys\QualysAgent", "C:\ProgramData\Qualys\QualysAgent")
    foreach ($path in $qualysPaths) {
        if (Test-Path $path) {
            Write-Host "Closing Explorer windows for $path"
            Stop-Process -Name explorer -Force
        }
    }

    # Run the uninstall command silently
    try {
        Write-Host "Running uninstall command..."
        Start-Process cmd.exe -ArgumentList "/c $uninstallCommand" -NoNewWindow -Wait
        Write-Host "Uninstallation completed successfully!"
    }
    catch {
        Write-Host "An error occurred during uninstallation: $_"
    }

    # Restart Windows Explorer
    Write-Host "Restarting Windows Explorer..."
    Start-Process explorer.exe
} else {
    Write-Host "Uninstall.exe not found at the specified path: $uninstallExePath"
}
