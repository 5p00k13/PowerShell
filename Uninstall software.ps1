$computerName = "COMPUTERNAME" # Replace with the name of the domain computer
$softwareName = "SOFTWARE NAME" # Replace with the name of the software to be removed

$software = Get-WmiObject -Class Win32_Product -ComputerName $computerName -Filter "Name='$softwareName'"

if ($software) {
  $software.Uninstall()
  Write-Host "Software '$softwareName' has been uninstalled."
}
else {
  Write-Host "Software '$softwareName' not found."