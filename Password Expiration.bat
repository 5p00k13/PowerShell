@echo off
cls
:start
set /p a="name:"
DSQUERY USER -name *%a%* |DSGET USER -samid -display
set /p p="username:"
net user %p% /domain | find "Password expires" & "PasswordLastSet"
set choice=
set /p choice="Do you want to run again? Press 'y' and enter for Yes: "
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='y' goto start
