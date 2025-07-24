# Prompt the user for the username
$username = Read-Host "Enter the username"

# Get the last password reset for the specified user
(Get-AdUser -Identity $username -Properties pwdLastSet).pwdLastSet | ForEach-Object { [DateTime]::FromFileTime($_) }
