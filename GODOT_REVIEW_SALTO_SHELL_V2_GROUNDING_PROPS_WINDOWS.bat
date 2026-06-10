@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\reviewGodotSaltoShellV2GroundingPropsWindows.ps1" %*
exit /b %ERRORLEVEL%
