# Function to restart the script with elevated privileges
function Restart-WithElevatedPrivileges {
    $scriptPath = $MyInvocation.MyCommand.Path

    # Prompt the user for credentials
    $credentials = Get-Credential

    # Start the script with elevated privileges using the provided credentials
    $secPassword = $credentials.Password
    $user = $credentials.Username

    # Convert the SecureString password to plain text
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPassword))

    # Start PowerShell with credentials and elevated privileges
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Credential $user -PassThru -NoNewWindow
    exit
}

# Check if the script is running with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires elevated privileges. Please provide credentials."
    Restart-WithElevatedPrivileges
}

# Proceed with the rest of the script
$username = Read-Host -Prompt "Please enter the username"

$currentComputer = $Env:COMPUTERNAME
Write-Output "You are currently logged into: $currentComputer"
Write-Output ""

$logons = Get-EventLog -LogName Security -InstanceId 4624 -Newest 1000

$computers = $logons | Where-Object {
    $_.ReplacementStrings[5] -eq $username
} | Select-Object -Property TimeGenerated, @{Name="ComputerName";Expression={$_.ReplacementStrings[18]}} -Unique | 
Select-Object -First 5

if ($computers.Count -gt 0) {
    Write-Output "The last five computers you have logged into are:"
    $computers | ForEach-Object {
        Write-Output "Computer: $($_.ComputerName)"
        Write-Output "Time: $($_.TimeGenerated)"
    }
} else {
    Write-Output "No logon events were found for the specified user."
}
