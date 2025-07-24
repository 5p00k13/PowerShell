reg add HKLM\System\CurrentControlSet\Services\USBHUB3 /t REG_DWORD /v "Start" /d 3 /f
reg add HKLM\System\CurrentControlSet\Services\usbhub /t REG_DWORD /v "Start" /d 3 /f
reg add HKLM\System\CurrentControlSet\Services\USBSTOR /t REG_DWORD /v "Start" /d 3 /f

pause
