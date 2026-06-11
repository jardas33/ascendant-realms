@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\runGodotSaltoShellV2FullQaBenchmarkWindows.ps1" %*
exit /b %ERRORLEVEL%
