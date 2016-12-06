@echo off
pushd %~dp0 2>NUL
schtasks /create /tn "long-shutdown" /ru SYSTEM /sc ONSTART /tr "%cd%\task.bat" /RL HIGHEST
pause