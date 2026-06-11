@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\validateGodotSaltoShellV2FullQaWindows.ps1" %*
exit /b %ERRORLEVEL%
