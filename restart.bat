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
echo long-shutdown - RESTART %date% at %time%>>"%longshutdownlog%"
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

REM chkdsk %SystemDrive%
REM if /i not %ERRORLEVEL%==0 (
	REM echo DEBUG: %errorlevel% %bugger%
	REM echo CHKDSK: Errors found on %SystemDrive%. >>"%longshutdownlog%"
	REM fsutil dirty set %SystemDrive%
REM ) else (
	REM echo DEBUG: %errorlevel% %bugger%
	REM echo CHKDSK: No errors found on %SystemDrive%. >>"%longshutdownlog%"
REM )
fsutil dirty set %SystemDrive%
:: make the log when you log in
:: we use HKCU instead of HKLM so that its just for the user who ran this
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /v "long-shutdown" /t "REG_SZ" /d "powershell.exe \"%~dp0\chklog.ps1\""
REM reg add HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /v "long-shutdown" /t "REG_SZ" /d "powershell.exe -Command \"^& {get-winevent -FilterHashTable @{logname=\\""Application\\^"; id='1001'}^| ?{$_.providername –match \\"wininit\\"} ^| fl timecreated, message ^| out-file \\"$home\Desktop\CHKDSKResults.txt\\"}"""
:: i tried to simplify this using excape charcters, but just couldn't get it.
:: http://ss64.com/nt/syntax-esc.html
:: this command would work if pasted in cmd
:: powershell.exe -Command "& {get-winevent -FilterHashTable @{logname=\"Application\"; id='1001'}| ?{$_.providername –match \"wininit\"} | fl timecreated, message | out-file \"$home\Desktop\CHKDSKResults.txt\"}"
%SystemRoot%\System32\shutdown /r /f
echo. >>"%longshutdownlog%"