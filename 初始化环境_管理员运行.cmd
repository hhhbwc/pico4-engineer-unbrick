@echo off
setlocal EnableExtensions
title Pico 4 offline environment setup
cd /d "%~dp0"

net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo Administrator permission is required to install USB drivers.
  echo Requesting elevation...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo Installing bundled PICO USB and Qualcomm 9008 drivers...
pnputil /add-driver "Drivers\PICO\*.inf" /subdirs /install
if errorlevel 1 goto driverfail
pnputil /add-driver "Drivers\Qualcomm9008\*.inf" /subdirs /install
if errorlevel 1 goto driverfail

echo.
echo Tools are self-contained in this folder. No PATH changes are needed.
echo Verifying bundled tools:
"Tools\adb.exe" version
"Tools\fastboot.exe" --version
echo.
echo Setup complete. Reconnect the headset after switching ADB, Fastboot, or 9008 modes.
pause
exit /b 0

:driverfail
echo.
echo Driver installation failed. Check the output above; Windows may require a driver policy change.
pause
exit /b 1
