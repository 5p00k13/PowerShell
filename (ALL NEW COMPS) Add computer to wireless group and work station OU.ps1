# Prompt for admin credentials
$adminCreds = Get-Credential -Message "Enter your administrative credentials"

# Prompt for the computer name
$computerName = Read-Host "Enter the computer name"

# Identity of the group you want to add the computer to
$groupIdentity = "SEC_StreamlineWirelessControl"

# Get all OUs in the domain
$allOUs = Get-ADOrganizationalUnit -Filter * | Select-Object DistinguishedName

# Display the list of available OUs
Write-Host "Available OUs:"
$index = 1
$ouSelections = @{}
foreach ($ou in $allOUs) {
    Write-Host "$index. $($ou.DistinguishedName)"
    $ouSelections[$index] = $ou.DistinguishedName
    $index++
}

# Prompt the user to select an OU by index
$selectedIndex = Read-Host "Enter the index of the target OU"

if ($ouSelections.ContainsKey([int]$selectedIndex)) {
    $targetOU = $ouSelections[[int]$selectedIndex]

    # Check if the computer exists in Active Directory
    $computer = Get-ADComputer -Filter { Name -eq $computerName }

    if ($computer) {
        # Move the computer to the selected OU using the admin credentials
        Move-ADObject -Identity $computer.DistinguishedName -TargetPath $targetOU -Credential $adminCreds

        # Add the computer to the specified group using the admin credentials
        Add-ADGroupMember -Identity $groupIdentity -Members $computer -Credential $adminCreds

        Write-Host "Computer $($computer.Name) moved to OU $targetOU and added to the group $groupIdentity."
    } else {
        Write-Host "Computer with name $computerName not found in Active Directory."
    }
} else {
    Write-Host "Invalid index. Please enter a valid index."
}
