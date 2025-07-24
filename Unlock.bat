@echo off
title Unlock AD Account Script
:Start
cls
echo.
set /p username=Enter the username: 

:: Run PowerShell to check user details and lock status
powershell -NoProfile -ExecutionPolicy Bypass -Command "
    Import-Module ActiveDirectory;
    $user = Get-ADUser -Filter {SamAccountName -eq '%username%'} -Properties LockedOut, Name;
    if ($user -eq $null) { 
        Write-Host 'User not found.' -ForegroundColor Red;
        exit 1;
    };
    Write-Host 'User found: ' $user.Name -ForegroundColor Green;
    if ($user.LockedOut) { 
        Write-Host 'Account is LOCKED.' -ForegroundColor Red;
        exit 2;
    } else { 
        Write-Host 'Account is NOT locked.' -ForegroundColor Cyan;
        exit 0;
    }
"

:: Check PowerShell exit codes
if %errorlevel%==1 (
    echo User not found. Press any key to try again...
    pause >nul
    goto Start
)
if %errorlevel%==2 (
    set /p confirm=Do you want to unlock this account? (Y/N): 
    if /I "%confirm%"=="Y" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "
            Unlock-ADAccount -Identity '%username%';
            Write-Host 'Account has been UNLOCKED.' -ForegroundColor Green;
            pause
        "
        echo Account has been unlocked. Press any key to continue...
        pause >nul
    )
)

:: Restart the process
goto Start
