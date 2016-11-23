@echo off
REM directory

dism /online /NoRestart /cleanup-image /scanhealth /Logpath:"%userprofile%\desktop\dism_check.log"
if not %ERRORLEVEL%==0 (
	:: Add /LimitAccess flag to this command to prevent connecting to Windows Update for replacement files
	Dism /Online /NoRestart /Cleanup-Image /RestoreHealth /Logpath:"%userprofile%\desktop\dism_repair.log"
) else (
	echo DISM: No image corruption detected.
)

sfc /scannow

chkdsk %SystemDrive%
if /i not %ERRORLEVEL%==0 (
	echo Errors found on %SystemDrive%.
	fsutil dirty set %SystemDrive%
	copy temp.bat "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
	shutdown /r /f
) else (
	echo No errors found on %SystemDrive%.
	shutdown /s /f
)

