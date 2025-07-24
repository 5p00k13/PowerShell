$computerName = "	KTHOUSIF-LPTP" # Replace with the name of the domain computer

$softwareList = Get-WmiObject -Class Win32_Product -ComputerName $computerName | Select-Object -Property Name

$softwareList
