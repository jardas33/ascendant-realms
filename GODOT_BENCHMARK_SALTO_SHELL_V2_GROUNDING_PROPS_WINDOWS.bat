@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\runGodotSaltoShellV2GroundingPropsBenchmarkWindows.ps1" %*
exit /b %ERRORLEVEL%
