# Create the script to run
$script = {
    # Prompt the user to enter the new computer name
    $newComputerName = Read-Host "Enter the new computer name"

    # Rename the computer
    Rename-Computer -NewName $newComputerName
}

# Convert the script to a string
$scriptString = [scriptblock]::Create($script).ToString()

# Launch the PowerShell console as an administrator and run the script
Start-Process powershell.exe -Verb runAs -ArgumentList "-Command $scriptString"