# Import Active Directory module if not already imported
Import-Module ActiveDirectory | Out-Null

# Specify the username
$user = "jphillips"

# Path to output file (ensure it is a file, not just a folder)
$outputFile = "C:\Users\clewis\Desktop\Reports\DisabledAccountsLog.txt"

# Ensure the output folder exists
$outputFolder = Split-Path -Path $outputFile
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
}

# Get the user object from Active Directory
$userObj = Get-ADUser -Identity $user -Properties whenChanged, userAccountControl, LastLogonTimestamp

# Check if the account is disabled
if ($userObj.userAccountControl -band 2) {
    # Construct the output
    $output = @"
User: $($userObj.SamAccountName)
Disabled On: $($userObj.whenChanged)
Last Known Logon: $([datetime]::FromFileTime($userObj.LastLogonTimestamp))
"@

    # Write to the output file
    Add-Content -Path $outputFile -Value $output

    Write-Host "Information logged to $outputFile"
} else {
    Write-Host "The account '$($userObj.SamAccountName)' is not disabled."
}
