@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\captureGodotSaltoShellV2GroundingLightingWindows.ps1" %*
