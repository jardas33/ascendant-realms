@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\validateGodotSaltoWorkerBarracksArtExperimentWindows.ps1" %*
