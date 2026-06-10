@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\reviewGodotSaltoShellV2StructureMaterialWindows.ps1" %*
exit /b %ERRORLEVEL%
