@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo === ADB ===
"Tools\adb.exe" start-server
"Tools\adb.exe" devices -l
echo.
echo === Qualcomm 9008 ===
powershell -NoProfile -Command "$d=Get-CimInstance Win32_PnPEntity | Where-Object {$_.Name -match '9008'};if($d){$d | Select-Object Name,Status,PNPDeviceID | Format-List}else{'No Qualcomm 9008 device detected.'}"
echo.
echo For Fastboot mode, run: Tools\fastboot.exe devices
pause
