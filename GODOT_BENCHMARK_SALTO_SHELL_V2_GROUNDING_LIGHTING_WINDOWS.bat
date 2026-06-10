@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\runGodotSaltoShellV2GroundingLightingBenchmarkWindows.ps1" %*
