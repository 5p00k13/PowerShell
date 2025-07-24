# Stop the Windows Update service
Stop-Service -Name wuauserv -Force > $null 2>&1

# Wait for the service to stop
while ((Get-Service -Name wuauserv).Status -eq 'Running') {
    Start-Sleep -Seconds 5
}

# Start the Windows Update service
Start-Service -Name wuauserv > $null 2>&1

# Wait for the service to start
while ((Get-Service -Name wuauserv).Status -eq 'Stopped') {
    Start-Sleep -Seconds 5
}
