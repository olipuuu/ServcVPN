@echo off
echo Starting ServcVPN...
echo.

REM Start Go core in background
echo [1/2] Starting VPN core engine...
start /B "" "%~dp0build\vpncli.exe" serve --port 50051

REM Wait for core to start
timeout /t 2 /nobreak > NUL

REM Start Flutter GUI
echo [2/2] Starting GUI...
start "" "%~dp0app\build\windows\x64\runner\Release\servc_vpn.exe"

echo.
echo ServcVPN is running.
echo Press Ctrl+C to stop the core engine.
echo.

REM Wait for the core to exit
wait
