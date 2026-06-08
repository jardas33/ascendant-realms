@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\validateGodotSaltoThreeSlotVisualHardeningWindows.ps1" %*
