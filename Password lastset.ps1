# Import the Active Directory module (if not already imported)
Import-Module ActiveDirectory

# Ask for the username
$username = Read-Host -Prompt "Enter the username"

# Get the password last set date
$user = Get-ADUser -Identity $username -Properties "PasswordLastSet"
$passwordLastSet = $user.PasswordLastSet

# Output the result
Write-Host "The password for user $username was last set on: $passwordLastSet"
