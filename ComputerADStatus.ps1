# Define the FQDN of the computer
$computerFQDN = "jhusain-lenox2.smartcarenet.com"

# Import the Active Directory module if not already imported
Import-Module ActiveDirectory

# Find the computer account in Active Directory by its FQDN
$computer = Get-ADComputer -Filter { DNSHostName -eq $computerFQDN } -Properties Enabled, LastLogonDate, whenChanged, DistinguishedName

if ($computer) {
    # Check if the computer is disabled
    if (-not $computer.Enabled) {
        Write-Host "The computer '$($computer.Name)' is disabled."
        
        # Get the date when it was disabled by checking the 'whenChanged' property
        $disabledDate = $computer.whenChanged
        Write-Host "The computer was disabled on: $disabledDate"
    } else {
        Write-Host "The computer '$($computer.Name)' is enabled."
    }

    # Get the current Organizational Unit (OU)
    $distinguishedName = $computer.DistinguishedName
    Write-Host "The computer's current OU is: $distinguishedName"
} else {
    Write-Host "Computer '$computerFQDN' not found in Active Directory."
}
