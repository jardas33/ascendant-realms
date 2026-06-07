@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\validateGodotSaltoWorkerBarracksArtOptInHardeningWindows.ps1" %*
