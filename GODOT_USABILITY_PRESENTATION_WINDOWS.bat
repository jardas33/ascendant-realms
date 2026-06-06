@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\runGodotUsabilityPresentationWindows.ps1"
exit /b %ERRORLEVEL%
