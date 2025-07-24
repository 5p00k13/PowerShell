@echo off
:start
set /p "a=name: "
DSQUERY USER -name *%a%* | DSGET USER -samid -display
set /p "p=username: "

REM Use PowerShell to check if the user is locked
powershell -Command "Import-Module ActiveDirectory; $user = Get-ADUser -Filter {SamAccountName -eq '%p%'}; Write-Host 'LockoutTime:' $user.LockoutTime; if ($user.LockoutTime -ne $null) { exit 1 } else { exit 0 }"
echo Error level: %errorlevel%
if %errorlevel% equ 1 (
    echo User %p% is locked.
    set /p "unlock=Do you want to unlock the account? (y/n): "
    if /i "%unlock%"=="y" (
        powershell -Command "Import-Module ActiveDirectory; Unlock-ADAccount -Identity '%p%'"
        echo User %p% has been unlocked.
    )
) else (
    echo User %p% is not locked.
)

set "choice="
set /p "choice=Do you want to run again? Press 'y' and enter for Yes: "
if not "%choice%"=="" set "choice=%choice:~0,1%"
if "%choice%"=="y" goto start