# Get the list of active users without an email address
$usersWithoutEmail = Get-ADUser -Filter {Enabled -eq $true -and EmailAddress -notlike "*"} -Property DisplayName, EmailAddress | Where-Object {
    $_.EmailAddress -eq $null
}

# Display the users
foreach ($user in $usersWithoutEmail) {
    Write-Output "User: $($user.DisplayName) does not have an email address set."
}