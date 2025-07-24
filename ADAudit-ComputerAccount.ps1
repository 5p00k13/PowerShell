$computerName = Read-Host "Enter the name of the computer to check"
$computer = Get-ADComputer -Identity $computerName -Properties Enabled, WhenChanged, LastLogonTimeStamp

if (!$computer) {
    Write-Warning "The specified computer '$computerName' could not be found in Active Directory."
} elseif ($computer.Enabled) {
    Write-Warning "The specified computer '$computerName' is currently enabled."
} else {
    $disabledDate = $computer.WhenChanged
    if ($disabledDate) {
        $dateString = $disabledDate.ToShortDateString()
        $timeString = $disabledDate.ToShortTimeString()
        Write-Host "The specified computer '$computerName' was disabled on $dateString at $timeString."
    } else {
        Write-Warning "The specified computer '$computerName' has never been disabled."
    }
    
    $lastModified = [DateTime]::FromFileTime($computer.LastLogonTimeStamp)
    $lastModifiedString = $lastModified.ToShortDateString() + " " + $lastModified.ToShortTimeString()
    Write-Host "The last modified date of the computer account is $lastModifiedString."
}
