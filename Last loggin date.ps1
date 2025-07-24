# Prompt the user for the username
$username = Read-Host "Enter the username you want to search for"

# Get the user object
$user = Get-AdUser -Filter {SamAccountName -eq $username} -Properties LastLogon

if ($user -ne $null) {
    # Convert LastLogon timestamp to readable date and time
    $lastLogon = [DateTime]::FromFileTime($user.LastLogon)
    Write-Host "User '$username' last signed into a computer at '$lastLogon'"

    # Get the computer name based on the LastLogon attribute
    $lastLogonComputer = Get-AdComputer -Filter { LastLogon -eq $user.LastLogon } | Select-Object -ExpandProperty Name

    Write-Host "User '$username' last signed into computer '$lastLogonComputer'"
} else {
    Write-Host "User '$username' not found in Active Directory."
}
