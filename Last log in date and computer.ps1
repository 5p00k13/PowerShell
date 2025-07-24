# Check if the script is running with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need to run this script as an administrator."
    pause
    exit
}

# Proceed with the rest of your script
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
