@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\reviewGodotSaltoEnvironmentGeometryConvergenceWindows.ps1" %*
