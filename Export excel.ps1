# Install the ImportExcel module if not already installed
if (-not (Get-Module -Name ImportExcel -ListAvailable)) {
    Install-Module -Name ImportExcel -Force -SkipPublisherCheck
}

# Import the ImportExcel module
Import-Module ImportExcel

# Prompt the user for credentials
$credentials = Get-Credential -Message "Enter your credentials"

# Get all users who are members of the "USEmployees" group using the provided credentials
$users = Get-ADGroupMember -Identity "USEmployees" -Recursive | Get-ADUser -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed", "EmailAddress" -Credential $credentials

# Get all users who are members of the "Bangalore_users" group using the provided credentials
$excludedUsers = Get-ADGroupMember -Identity "Bangalore_users" -Recursive | Get-ADUser -Properties "DistinguishedName"

# Filter users based on the current month and year and exclude users from "Bangalore_users" group
$filteredUsers = $users | Where-Object {
    $_."msDS-UserPasswordExpiryTimeComputed" -ge $firstDayOfMonth.ToFileTime() -and
    $_."msDS-UserPasswordExpiryTimeComputed" -le $lastDayOfMonth.ToFileTime() -and
    -not (Get-ADUser $_.SamAccountName -Properties MemberOf).MemberOf -contains "CN=Bangalore_users,CN=Users,DC=yourdomain,DC=com"
}


# Define the path to the Excel file
$excelFilePath = "C:\ExpiredPasswords\PasswordExpiryReport.xlsx"

# Export the results to an Excel file
$filteredUsers | Select-Object -Property "DisplayName", "EmailAddress", @{
    Name = "ExpiryDate"
    Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}
} | Export-Excel -Path $excelFilePath -AutoSize -FreezeTopRow -BoldTopRow
