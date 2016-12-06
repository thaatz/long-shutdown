@echo off
REM directory
echo long-shutdown - %date% at %time%>>"%userprofile%\desktop\long-shutdown.log"
dism /online /NoRestart /cleanup-image /scanhealth /Logpath:"%userprofile%\desktop\dism_check.log"
if not %ERRORLEVEL%==0 (
	:: Add /LimitAccess flag to this command to prevent connecting to Windows Update for replacement files
	Dism /Online /NoRestart /Cleanup-Image /RestoreHealth /Logpath:"%userprofile%\desktop\dism_repair.log"
	if not %ERRORLEVEL%==0 (
		echo DEBUG: %errorlevel% >>"%userprofile%\desktop\long-shutdown.log"
		echo DISM: There was an issue with the DISM repair. >>"%userprofile%\desktop\long-shutdown.log"
	) else (
		echo DEBUG: %errorlevel% >>"%userprofile%\desktop\long-shutdown.log"
		echo DISM: Image repaired successfully. >>"%userprofile%\desktop\long-shutdown.log"
	)
) else (
	echo DEBUG: %errorlevel% >>"%userprofile%\desktop\long-shutdown.log"
	echo DISM: No image corruption detected. >>"%userprofile%\desktop\long-shutdown.log"
)

sfc /scannow
if not %ERRORLEVEL%==0 (
	echo DEBUG: %errorlevel% >>"%userprofile%\desktop\long-shutdown.log"
	echo SFC: There was an issue with the SFC repair. >>"%userprofile%\desktop\long-shutdown.log"
) else (
	echo DEBUG: %errorlevel% >>"%userprofile%\desktop\long-shutdown.log"
	echo SFC: SFC completed sucessfully. >>"%userprofile%\desktop\long-shutdown.log"
)

chkdsk %SystemDrive%
if /i not %ERRORLEVEL%==0 (
	echo DEBUG: %errorlevel% >>"%userprofile%\desktop\long-shutdown.log"
	echo CHKDSK: Errors found on %SystemDrive%. >>"%userprofile%\desktop\long-shutdown.log"
	fsutil dirty set %SystemDrive%
	copy temp.bat "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
	shutdown /r /f
) else (
	echo DEBUG: %errorlevel% >>"%userprofile%\desktop\long-shutdown.log"
	echo CHKDSK: No errors found on %SystemDrive%. >>"%userprofile%\desktop\long-shutdown.log"
	shutdown /s /f
	REM shutdown /r /f
)
echo. >>"%userprofile%\desktop\long-shutdown.log"