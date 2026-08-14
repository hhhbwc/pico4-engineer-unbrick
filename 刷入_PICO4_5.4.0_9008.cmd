@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Pico 4 5.4.0 - Qualcomm 9008 flash
set "ROOT=%~dp0"
set "FLASH=%ROOT%Flash"
set "FH=%ROOT%fh_loader.exe"
set "SAHARA=%ROOT%QSaharaServer.exe"
set "FIREHOSE=%ROOT%prog_firehose_ddr.elf"
set "RAW=%ROOT%rawprogram_pico4_5.4.0.xml"
set "LOG=%ROOT%flash_5.4.0_complete.log"

if /I "%~1"=="CHECK" goto check
if "%~1"=="" goto autodetect
set "PORT=%~1"
echo %PORT%| findstr /R /I "^COM[0-9][0-9]*$" >nul || goto badport
goto portready

:autodetect
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$ports=Get-CimInstance Win32_PnPEntity | Where-Object {$_.Name -match '9008' -and $_.Name -match '\(COM[0-9]+\)'} | ForEach-Object {[regex]::Match($_.Name,'\(COM[0-9]+\)').Groups[1].Value}; if($ports.Count -eq 1){$ports[0]}"`) do set "PORT=%%P"
if defined PORT (
  echo Detected the only Qualcomm 9008 device: %PORT%
  goto portready
)

:promptport
cls
echo Pico 4 5.4.0 Qualcomm 9008 flash
echo.
echo No unique Qualcomm 9008 port was found.
echo Connect the headset in 9008 mode, or enter its port manually, for example COM3.
echo.
set /p "PORT=9008 port (or Q to quit): "
if /I "%PORT%"=="Q" goto cancelled
echo %PORT%| findstr /R /I "^COM[0-9][0-9]*$" >nul || goto badportpause

:portready
:check
for %%F in ("%FH%" "%SAHARA%" "%FIREHOSE%" "%RAW%" "%FLASH%\lun0_super.bin" "%FLASH%\lun1_xbl.bin" "%FLASH%\lun4_abl.bin" "%FLASH%\lun4_modem.bin" "%FLASH%\lun4_boot.bin") do if not exist "%%~F" (echo ERROR: Missing %%~F& goto errorpause)
if /I "%~1"=="CHECK" (echo OK: required 5.4.0 files found.& exit /b 0)

echo WARNING: This writes the complete 5.4.0 OS, boot chain, DSP, modem and security firmware.
echo It does NOT write GPT, userdata, persist, cache, EFS/modemst, devinfo or calibration data.
echo Target Qualcomm 9008 port: %PORT%
set /p "CONFIRM=Type FLASH_5.4.0 to start: "
if /I not "%CONFIRM%"=="FLASH_5.4.0" (echo Cancelled. Nothing written.& exit /b 1)

echo [%date% %time%] Flash start %PORT% > "%LOG%"
echo Stage 1/2: sending the Firehose programmer through Sahara...
"%SAHARA%" -p \\.\%PORT% -s 13:"%FIREHOSE%" -b "%ROOT%/"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (echo FAILED: Firehose programmer was not accepted. Exit %RC%.& goto errorpause)

echo Stage 2/2: writing the selected 5.4.0 partitions...
"%FH%" --port=\\.\%PORT% --sendxml="%RAW%" --search_path="%FLASH%" --memoryname=ufs --zlpawarehost=1 --noprompt --showpercentagecomplete --porttracename="%LOG%"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (echo FAILED, exit %RC%. Check "%LOG%".& goto errorpause)
echo SUCCESS: write completed. Keep power connected and wait two minutes before booting.
pause
exit /b 0

:usage
echo Usage: "%~nx0" COM3
echo Check only: "%~nx0" CHECK
exit /b 1
:badport
echo ERROR: Port must be COM3, COM10, etc.
exit /b 1
:badportpause
echo.
echo ERROR: Port must be COM3, COM10, etc.
pause
exit /b 1
:cancelled
echo Cancelled. Nothing written.
pause
exit /b 1
:errorpause
echo.
pause
exit /b 2
