# Open the "Your info" settings page
Start-Process "ms-settings:yourinfo"

# Wait for the settings page to open
Start-Sleep -Seconds 5

# Simulate key presses to sign out of the current Microsoft account
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{TAB}{TAB}{ENTER}")

# Wait for the sign-out process to complete
Start-Sleep -Seconds 10

# Open the "Your info" settings page again
Start-Process "ms-settings:yourinfo"

# Wait for the settings page to open
Start-Sleep -Seconds 5

# Simulate key presses to sign back into the Microsoft account
[System.Windows.Forms.SendKeys]::SendWait("{TAB}{TAB}{ENTER}")