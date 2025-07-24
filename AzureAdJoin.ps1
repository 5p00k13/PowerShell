$maxAttempts = 10
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $status = dsregcmd.exe /status
    if ($status -match "AzureAdJoined\s*:\s*YES") {
        Write-Output "Device is fully registered."
        break
    } else {
        Write-Output "Device is not fully registered. Attempting re-registration..."
        dsregcmd.exe /join
        Start-Sleep -Seconds 60
        $attempt++
    }
}

if ($attempt -ge $maxAttempts) {
    Write-Output "Failed to register the device after $maxAttempts attempts."
}
