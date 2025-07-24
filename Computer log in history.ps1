$computerName = Read-Host "Enter the computer name"
Get-WinEvent -ComputerName $computerName -FilterHashtable @{LogName='Security';ID='4624'} | Select-Object -Property TimeCreated,Message
