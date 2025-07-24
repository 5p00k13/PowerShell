$firstName = Read-Host "Enter user's first name"
$users = Get-ADUser -Filter {GivenName -like "$firstName*" -or Surname -like "$firstName*"} -Properties GivenName, SamAccountName
if ($users) {
    foreach ($user in $users) {
        Write-Host "Given Name: $($user.GivenName)"
        Write-Host "SamAccountName: $($user.SamAccountName)"
    }
} else {
    Write-Host "No users found with a first name or surname that starts with '$firstName'."
}


pause
do {
    $username = Read-Host "Enter the username to see the password information: "
    $selectedUser = Get-ADUser -Identity $username -Properties *
    Write-Host "Username: $($selectedUser.SamAccountName)"
    Write-Host "Password last set: $($selectedUser.PasswordLastSet)"
    Write-Host "Password expires: $($selectedUser.PasswordExpired)"
    $choice = Read-Host "Do you want to run again? Press 'y' and enter for Yes"
} while ($choice -eq 'y')