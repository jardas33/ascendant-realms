@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\launchGodotStabilizedSaltoReviewWindows.ps1" %*
