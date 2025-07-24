@echo off
set /p a="name: "
DSQUERY USER -name *%a%* | DSGET USER -samid -display
pause