$existingUser = Read-Host "Enter the name of the existing user"
$newUser = Read-Host "Enter the name of the new user"

# Get all AD groups that the existing user is a member of
$groups = Get-ADUser $existingUser -Properties memberof | Select-Object -ExpandProperty memberof

# Add the new user to each group
foreach ($group in $groups) {
  Add-ADGroupMember -Identity $group -Members $newUser
}
