@echo off
CLS
COLOR 0A
REM Start Putty and create a tunnel to be used as a Socks Proxy
ECHO ++++++++++++++++++
ECHO + Tunnel Starter +
ECHO ++++++++++++++++++
ECHO.
ECHO Initializing ...
REM Let's start by setting a few variables
SET ssh_host=vasoldsberg.vigier.at
SET ssh_port=443
SET ssh_user=
SET ssh_pass=
SET socks_port=1337
SET putty_exe="C:\Program Files\PuTTY\putty.exe"
SET chrome_default_exe="C:\Users\bvig\Personal-Private\Locker\GoogleChromePortable\App\Chrome-bin\chrome.exe"
SET chrome_portable_exe="C:\Users\bvig\Personal-Private\Locker\GoogleChromePortable\GoogleChromePortable.exe"
SET wait_timer=15

ECHO Done!
ECHO.
REM Now let's create our tunnel and (re)start Chrome
ECHO Checking if Putty is running, and killing it if needed...
FOR %%F IN (%putty_exe%) DO SET putty_exe_file=%%~nxF
tasklist /fi "imagename eq %putty_exe_file%"  |find ":" > nul
IF ERRORLEVEL 1 taskkill /f /im "%putty_exe_file%"
ECHO Done!
ECHO Creating SSH tunnel to %ssh_host%:%ssh_port%, SOCKS5 listening locally on port %socks_port%...
START "Putty" %putty_exe% -ssh -l %ssh_user% -pw %ssh_pass% -D %socks_port% -P %ssh_port% %ssh_host% -N
ECHO Done!
REM | CHOICE /C:AB /T:A,%wait_timer% > NUL
IF ERRORLEVEL 255 ECHO Invalid parameter
ECHO.
ECHO Checking if Chrome is running, and killing it if needed...
FOR %%F IN (%chrome_default_exe%) DO SET chrome_exe_file=%%~nxF
tasklist /fi "imagename eq %chrome_default_exe%"  |find ":" > nul
IF ERRORLEVEL 1 taskkill /f /im "%chrome_default_exe%"
ECHO Done!
ECHO.
ECHO Starting Chrome with SOCKS5 Enabled"
START "Chrome" %chrome_portable_exe% --proxy-server="socks5://localhost:%socks_port%" --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost"
ECHO Done!
ECHO.
ECHO Exiting...
::EXIT
