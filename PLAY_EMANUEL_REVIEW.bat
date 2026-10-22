@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\review\run_playable_review.ps1"
if errorlevel 1 pause
endlocal
