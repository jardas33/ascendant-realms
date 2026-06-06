@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\runGodotBlockoutQualityWindows.ps1"
exit /b %ERRORLEVEL%
