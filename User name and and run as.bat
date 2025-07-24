@echo off

:setname
set /p search_name="Enter a name to search for: "
echo Searching for users with name: %search_name%
echo.

for /f "tokens=1,2" %%a in ('DSQUERY USER -name *%search_name%* ^| DSGET USER -samid -display') do (
    echo Username: %%a
    echo Display Name: %%b
    echo.
)

set /p selected_user="Enter the username of the user you want to run cmd.exe as: "
echo Running cmd.exe as user: %selected_user%
echo.

Runas.exe /user:%selected_user% cmd.exe

