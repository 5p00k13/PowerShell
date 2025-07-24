#Chris's ping test

$i=0;do{try {Test-Connection forticentralsc.smartcarenet.com -count 2 -ErrorAction Stop;++$i}catch{"failed to reach forticentralsc.smartcarenet.com on attempt $i at $(get-date)";++$i;Start-Sleep -Seconds 2}}until($i -eq 50)

#Mine

$i=0; do { try { Test-Connection forticentralsc.smartcarenet.com -Count 2 -ErrorAction Stop; Write-Host "Successfully reached forticentralsc.smartcarenet.com on attempt $i at $(Get-Date)"; } catch { $errorMessage=$_.Exception.Message; $errorCategory=$_.CategoryInfo.Category; Write-Host "Failed to reach forticentralsc.smartcarenet.com on attempt $i at $(Get-Date)"; Write-Host "Reason: $errorMessage ($errorCategory)"; } ++$i; Start-Sleep -Seconds 2; } until ($i -eq 50)

#Trace route

tracert forticentralsc.smartcarenet.com

#BlueToothe Enable

Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Bluetooth*" -and $_.Status -eq "Disabled" } | ForEach-Object { Enable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false }

#BlueTooth Disable

Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Bluetooth*" -and $_.Status -eq "OK" } | ForEach-Object { Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false }
