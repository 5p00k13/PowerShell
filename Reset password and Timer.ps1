$username = Read-Host -Prompt "Enter the username of the user whose password you want to reset"
Set-ADAccountPassword -Identity $username -Reset
$user = Get-ADUser -Identity $username -Properties PasswordExpired, PasswordLastSet
$expirationDate = $user.PasswordLastSet + (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
Write-Host "$username's new password expiration date is: $expirationDate"
