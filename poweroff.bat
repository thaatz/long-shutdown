@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: USER SETTINGS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set longshutdownlog=%userprofile%\desktop\long-shutdown.log
set debug=1
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if %debug% EQU 1 (
	set bugger=^>^>"%longshutdownlog%"
) else (
	set bugger=^>nul
)

REM pushd %~dp0 2>NUL
echo long-shutdown - SHUTDOWN %date% at %time%>>"%longshutdownlog%"
dism /online /NoRestart /cleanup-image /scanhealth /Logpath:"%userprofile%\desktop\dism_check.log"
if not %ERRORLEVEL%==0 (
	:: Add /LimitAccess flag to this command to prevent connecting to Windows Update for replacement files
	Dism /Online /NoRestart /Cleanup-Image /RestoreHealth /Logpath:"%userprofile%\desktop\dism_repair.log"
	if not %ERRORLEVEL%==0 (
		echo DEBUG: %errorlevel% %bugger%
		echo DISM: There was an issue with the DISM repair. >>"%longshutdownlog%"
	) else (
		echo DEBUG: %errorlevel% %bugger%
		echo DISM: Image repaired successfully. >>"%longshutdownlog%"
	)
) else (
	echo DEBUG: %errorlevel% %bugger%
	echo DISM: No image corruption detected. >>"%longshutdownlog%"
)

sfc /scannow
if not %ERRORLEVEL%==0 (
	echo DEBUG: %errorlevel% %bugger%
	echo SFC: There was an issue with the SFC repair. >>"%longshutdownlog%"
) else (
	echo DEBUG: %errorlevel% %bugger%
	echo SFC: SFC completed sucessfully. >>"%longshutdownlog%"
)

:: make the log when you log in
:: we use HKCU instead of HKLM so that its just for the user who ran this
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /v "long-shutdown" /t "REG_SZ" /d "powershell.exe \"%~dp0\chklog.ps1\""
chkdsk %SystemDrive%
if /i not %ERRORLEVEL%==0 (
	echo DEBUG: %errorlevel% %bugger%
	echo CHKDSK: Errors found on %SystemDrive%. >>"%longshutdownlog%"
	fsutil dirty set %SystemDrive%
	REM copy temp.bat "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
	schtasks /create /tn "long-shutdown" /ru SYSTEM /sc ONSTART /tr "%cd%\task.bat" /RL HIGHEST
	REM reg add HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce /v "long-shutdown" /t "REG_SZ" /d "%SystemRoot%\System32\shutdown /s /f"
	%SystemRoot%\System32\shutdown /r /f
) else (
	echo DEBUG: %errorlevel% %bugger%
	echo CHKDSK: No errors found on %SystemDrive%. >>"%longshutdownlog%"
	%SystemRoot%\System32\shutdown /s /f
	REM shutdown /r /f
)
echo. >>"%longshutdownlog%"