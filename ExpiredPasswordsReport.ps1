# Define the number of days before expiration to notify users
$notificationDays = @(14, 7)

# Get the current date
$currentDate = Get-Date

# Function to display notification
function Display-PasswordExpiryNotification {
    param (
        [string]$displayName,
        [datetime]$expiryDate,
        [int]$daysLeft
    )
    Write-Output "User: $displayName, Password Expiry Date: $expiryDate, Days Left: $daysLeft"
}

# Get the list of users whose passwords are about to expire
$users = Get-ADUser -Filter * -Property DisplayName, EmailAddress, msDS-UserPasswordExpiryTimeComputed, Enabled | Where-Object {
    $_."msDS-UserPasswordExpiryTimeComputed" -ne $null -and $_.Enabled -eq $true
}

# Check each user for password expiration
foreach ($user in $users) {
    $expiryTime = $user."msDS-UserPasswordExpiryTimeComputed"
    if ($expiryTime -gt 0 -and $expiryTime -lt [datetime]::MaxValue.ToFileTime()) {
        try {
            $expiryDate = [datetime]::FromFileTime($expiryTime)
            $daysLeft = ($expiryDate - $currentDate).Days

            if ($notificationDays -contains $daysLeft -or $daysLeft -lt 7 -and $daysLeft -gt 0) {
                Display-PasswordExpiryNotification -displayName $user.DisplayName -expiryDate $expiryDate -daysLeft $daysLeft
            }
        } catch {
            # Skip users with invalid password expiry time
        }
    }
}