# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for the source and target user names
$sourceUser = Read-Host "Source"
$targetUser = Read-Host "Target"

# Get all groups of the source user
$sourceGroups = Get-ADUser -Identity $sourceUser -Property MemberOf | Select-Object -ExpandProperty MemberOf

# Show a list of groups that will be copied
Write-Host "`nThe following groups will be copied from $sourceUser to $targetUser:" -ForegroundColor Cyan
$sourceGroups | ForEach-Object { (Get-ADGroup $_).SamAccountName }

# Add the target user to each group
foreach ($group in $sourceGroups) {
    # Extract the group name from the Distinguished Name
    $groupName = (Get-ADGroup -Identity $group).SamAccountName
    Add-ADGroupMember -Identity $groupName -Members $targetUser
    Write-Host "Added $targetUser to group $groupName"
}

Write-Host "Group membership copying completed."

