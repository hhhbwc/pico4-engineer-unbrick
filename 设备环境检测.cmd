@echo off
setlocal EnableExtensions
title Pico 4 connection environment check
echo === Android platform-tools ===
where adb
where fastboot
adb version
fastboot --version
echo.
echo === ADB devices ===
adb devices -l
echo.
echo === Qualcomm 9008 ports ===
powershell -NoProfile -Command "$devices=Get-CimInstance Win32_PnPEntity | Where-Object {$_.Name -match '9008'}; if($devices){$devices | Select-Object Name,Status,PNPDeviceID | Format-List}else{'No Qualcomm 9008 device is connected.'}"
echo.
echo === Notes ===
echo ADB mode: device should appear under ADB devices.
echo Fastboot mode: run "fastboot devices" after manually entering bootloader mode.
echo EDL mode: this script should show Qualcomm HS-USB QDLoader 9008 (COMx).
echo.
pause
