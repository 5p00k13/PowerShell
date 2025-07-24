# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt the user for the username
$username = Read-Host "Enter the username"

# Get the user object from Active Directory
$user = Get-AdUser -Filter {SamAccountName -eq $username} -Properties PasswordLastSet

# Check if the user object was found
if ($user) {
    # Display the PasswordLastSet value
    if ($user.PasswordLastSet) {
        Write-Host "Last Password Reset for $($username): $($user.PasswordLastSet)"
    } else {
        Write-Host "User $($username) has never had a password reset."
    }
} else {
    Write-Host "User $username not found in Active Directory."
}
