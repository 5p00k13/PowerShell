$computerName = "DESKTOP-6U6LD1V" # Replace with the name of the domain computer
$softwareName = "ScreenConnect Client (0b7a9d93c3401498)" # Replace with the name of the software to be removed

$software = Get-WmiObject -Class Win32_Product -ComputerName $computerName -Filter "Name='$softwareName'"

if ($software) {
  $software.Uninstall()
  Write-Host "Software '$softwareName' has been uninstalled."
}
else {
  Write-Host "Software '$softwareName' not found."
}
