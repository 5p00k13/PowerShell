#Apps to remove defined
$appsToRemove = @(
    "Microsoft.ZuneMusic",         # Groove Music
    "Microsoft.XboxApp",           # Xbox App
    "Microsoft.SkypeApp",          # Skype
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.Microsoft3DViewer"
)
# Remove spcified apps
foreach ($app in $appsToRemove) {
    Write-Host "Removing $app..."
    Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage
}

# Remove Xbox apps for all users
Write-Host "Removing Xbox apps..."
Get-AppxPackage -AllUsers -Name "*Xbox*" | Remove-AppxPackage

# Disable Xbox Live services
$servicesToStop = @("XblGameSave", "XboxGipSvc", "XboxNetApiSvc")

foreach ($service in $servicesToStop) {
    Write-Host "Stopping and disabling $service..."
    Stop-Service -Name $service -Force
    Set-Service -Name $service -StartupType Disabled
}

# Disable Xbox scheduled tasks
Write-Host "Disabling Xbox scheduled tasks..."
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Xbox*"} | Disable-ScheduledTask
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Game*"} | Disable-ScheduledTask



