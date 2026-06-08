@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\reviewGodotSaltoFourSlotArtWindows.ps1" %*
