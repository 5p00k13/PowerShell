@echo off
:: Self-elevate the batch file
:: ----------------------------
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Main logic
setlocal enabledelayedexpansion

set /p checkHealth=Do you want to check the health of the machine? (yes/no): 
if /i "%checkHealth%"=="yes" (
    DISM /Online /Cleanup-Image /CheckHealth
    echo.
    set /p continue=Do you want to continue with ScanHealth? (yes/no): 
    if /i "%continue%"=="yes" (
        DISM /Online /Cleanup-Image /ScanHealth
        echo.
        set /p restore=Do you want to run RestoreHealth? (yes/no): 
        if /i "%restore%"=="yes" (
            DISM /Online /Cleanup-Image /RestoreHealth
        )
    )
)

echo.
echo  All operations complete.
pause
exit /b

