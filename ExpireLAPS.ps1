$ComputerName = "MININT-9B837IL"

# Expire the LAPS password
Set-ADComputer -Identity $ComputerName -Replace @{ 'ms-Mcs-AdmPwdExpirationTime' = 0 }

# Verify the update
$Computer = Get-ADComputer -Identity $ComputerName -Properties ms-Mcs-AdmPwdExpirationTime
if ($Computer.'ms-Mcs-AdmPwdExpirationTime' -eq 0) {
    Write-Host "LAPS password expiration for $ComputerName successfully set to 0." -ForegroundColor Green
} else {
    Write-Host "Failed to update LAPS password expiration for $ComputerName." -ForegroundColor Red
}
