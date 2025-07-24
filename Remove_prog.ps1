# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Prompt for credentials
    $credential = Get-Credential

    # Start a new process running the script as an administrator
    Start-Process -FilePath PowerShell -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File `"$($MyInvocation.MyCommand.Path)`"" -Credential $credential -Verb RunAs

    # Exit the current script
    exit
}

# Create a form
$form = New-Object Windows.Forms.Form
$form.Text = "Program Uninstaller"
$form.Width = 800
$form.Height = 400

# Create a label
$label = New-Object Windows.Forms.Label
$label.Text = "Select a program to forcefully remove:"
$label.AutoSize = $true
$label.Font = New-Object Drawing.Font("Arial", 12)
$label.Location = New-Object Drawing.Point(10, 20)

# Create a drop-down list
$dropDownList = New-Object Windows.Forms.ComboBox
$dropDownList.Location = New-Object Drawing.Point(10, 50)
$dropDownList.Width = 760
$dropDownList.Font = New-Object Drawing.Font("Arial", 12)

# Get installed programs
$installedPrograms = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                     Where-Object { $_.DisplayName -and $_.UninstallString } |
                     Select-Object DisplayName, UninstallString, InstallLocation

# Populate the drop-down list with program names
foreach ($program in $installedPrograms) {
    if ($program.DisplayName) {
        [void]$dropDownList.Items.Add($program.DisplayName)
    }
}

# Create a remove button
$removeButton = New-Object Windows.Forms.Button
$removeButton.Text = "Forcefully Remove"
$removeButton.Location = New-Object Drawing.Point(10, 100)
$removeButton.Font = New-Object Drawing.Font("Arial", 12)
$removeButton.Width = 150

# Define the action when the button is clicked
$removeButton.Add_Click({
    try {
        $selectedProgram = $dropDownList.SelectedItem

        if (-not $selectedProgram) {
            throw "Please select a program to forcefully remove."
        }

        $programToUninstall = $installedPrograms | Where-Object { $_.DisplayName -eq $selectedProgram }

        if (-not $programToUninstall) {
            throw "Program not found."
        }

        $installDirectory = $programToUninstall.InstallLocation

        if (-not $installDirectory -or -not (Test-Path -Path $installDirectory -PathType Container)) {
            throw "Installation directory not found or does not exist."
        }

        Write-Host "Forcefully removing $($programToUninstall.DisplayName)..."
        Write-Host "Installation Directory: $installDirectory"

        # Attempt to remove the installation directory
        Remove-Item -Path $installDirectory -Recurse -Force -ErrorAction Stop
        Write-Host "Forceful removal complete."

        # Close the form after removal is complete
        $form.Close()
    } catch {
        # Display detailed error message
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Add controls to the form
$form.Controls.Add($label)
$form.Controls.Add($dropDownList)
$form.Controls.Add($removeButton)

# Show the form
[Windows.Forms.Application]::Run($form)
