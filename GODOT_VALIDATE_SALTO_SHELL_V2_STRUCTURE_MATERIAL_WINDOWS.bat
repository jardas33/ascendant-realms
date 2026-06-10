@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\validateGodotSaltoShellV2StructureMaterialWindows.ps1" %*
exit /b %ERRORLEVEL%
