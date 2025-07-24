PORTAGEDC05# Ensure the Active Directory module is imported
Import-Module ActiveDirectory

# Get the list of domain controllers
$domainControllers = Get-ADDomainController -Filter *

# Display the list of domain controllers
Write-Host "Available Domain Controllers:"
$domainControllers | ForEach-Object { Write-Host $_.Name }

# Prompt the user to enter the name of the domain controller to connect to
$dcName = Read-Host "Enter the name of the domain controller you want to connect to"

# Check if the entered name is valid
if ($domainControllers.Name -contains $dcName) {
    # Open an RDP session with the selected domain controller
    mstsc /v:$dcName
    Write-Host "RDP session started with $dcName"
} else {
    Write-Host "Invalid domain controller name. Please try again."
}