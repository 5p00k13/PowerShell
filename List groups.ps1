# Define the target user
$userToCheck = "jwalz"

# Function to log output to the console
function Log-Output {
    param (
        [string]$message
    )
    Write-Output $message
}

# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log-Output "Script is not running with administrative privileges. Please run the script as an administrator."
    exit
}

# Get all groups the user is a member of
Log-Output "Retrieving groups for user $userToCheck..."

try {
    $userGroups = Get-ADUser -Identity $userToCheck -Property MemberOf | Select-Object -ExpandProperty MemberOf
} catch {
    Log-Output "Error retrieving groups for user ${userToCheck}: $_"
    exit
}

if ($userGroups) {
    foreach ($group in $userGroups) {
        # Extract the group name from the distinguished name
        $groupName = ($group -split ',')[0] -replace '^CN=', ''
        Log-Output "`nChecking when ${userToCheck} was added to group ${groupName}..."

        try {
            # Search for events where the user was added to the group
            $events = Get-WinEvent -LogName Security -FilterXPath "*[System[(EventID=4728 or EventID=4732 or EventID=4756 or EventID=4761)] and EventData[Data[@Name='TargetUserName']='$groupName'] and EventData[Data[@Name='MemberName']='$userToCheck']]" -ErrorAction Stop

            if ($events) {
                foreach ($event in $events) {
                    $timeCreated = $event.TimeCreated
                    $userAdded = ($event | Select-Object -ExpandProperty Properties)[2].Value
                    $group = ($event | Select-Object -ExpandProperty Properties)[0].Value
                    $addedBy = ($event | Select-Object -ExpandProperty Properties)[5].Value

                    Log-Output "User ${userAdded} was added to group ${group} on ${timeCreated} by ${addedBy}."
                }
            } else {
                Log-Output "No events found for ${userToCheck} being added to group ${groupName}."
            }
        } catch {
            Log-Output "Error searching events for group ${groupName}: $_"
        }
    }
} else {
    Log-Output "User ${userToCheck} is not a member of any groups."
}
