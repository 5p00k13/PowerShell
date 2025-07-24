# Ensure the Active Directory module is imported
Import-Module ActiveDirectory

# Define the time period (3 months ago)
$threeMonthsAgo = (Get-Date).AddMonths(-3)

# Search for users in Active Directory
$staleUsers = Get-ADUser -Filter {Enabled -eq $true} -Properties LastLogonDate |
    Where-Object {
        $_.LastLogonDate -and ($_.LastLogonDate -lt $threeMonthsAgo)
    } |
    Select-Object Name, SamAccountName, LastLogonDate

# Display the results
if ($staleUsers) {
    $staleUsers | Format-Table -AutoSize
} else {
    Write-Host "No enabled users found who have not signed in over the last three months." -ForegroundColor Green
}
