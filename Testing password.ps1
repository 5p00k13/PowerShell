$username = Read-Host -Prompt "Enter the username of the user whose password expiration timer you want to reset"
$user = Get-ADUser -Identity $username
Set-ADUser -Identity $user -PasswordLastSet (Get-Date)
Write-Host "Password expiration timer for $username has been reset"
