@echo off
:: https://msdn.microsoft.com/powershell/reference/5.1/Microsoft.PowerShell.Core/about/about_Execution_Policies
REM powershell.exe Get-ExecutionPolicy -List
:: we figure out what the execution policy for currentuser is and save it for later
for /f "tokens=2*" %%i IN ('powershell.exe Get-ExecutionPolicy -List ^| find "CurrentUser"') DO set cu_ep=%%i
:: we change the execution policy for the currentuser to bypass
powershell.exe Set-ExecutionPolicy Bypass -Scope CurrentUser
powershell.exe %~dp0\chklog.ps1
:: we set the execution policy back to whatever it was before when we're done
powershell.exe Set-ExecutionPolicy %cu_ep% -Scope CurrentUser