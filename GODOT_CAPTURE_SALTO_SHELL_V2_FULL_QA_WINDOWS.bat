@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\captureGodotSaltoShellV2FullQaWindows.ps1" %*
exit /b %ERRORLEVEL%
