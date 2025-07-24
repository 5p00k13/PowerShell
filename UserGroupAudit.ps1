# Define the target user and group
$userToCheck = "jwalz"
$groupToCheck = "LUCAS_SFTP"

# Function to log output to the console
function Log-Output {
    param (
        [string]$message
    )
    Write-Output $message
}

# Check if running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Log-Output "Script is not running with administrative privileges. Please run the script as an administrator."
    exit
}

# Check for events where the user was added to a group
Log-Output "Searching for events where $userToCheck was added to $groupToCheck..."

try {
    $events = Get-WinEvent -LogName Security -FilterXPath "*[System[(EventID=4728 or EventID=4732)] and EventData[Data[@Name='TargetUserName']='$groupToCheck'] and EventData[Data[@Name='MemberName']='$userToCheck']]" -ErrorAction Stop

    if ($events) {
        foreach ($event in $events) {
            $timeCreated = $event.TimeCreated
            $userAdded = ($event | Select-Object -ExpandProperty Properties)[2].Value
            $group = ($event | Select-Object -ExpandProperty Properties)[0].Value
            $addedBy = ($event | Select-Object -ExpandProperty Properties)[5].Value

            Log-Output "`nUser $userAdded was added to group $group on $timeCreated by $addedBy."
        }
    } else {
        Log-Output "`nNo events found where $userToCheck was added to $groupToCheck."
    }
} catch {
    Log-Output "Error: $_"
}
