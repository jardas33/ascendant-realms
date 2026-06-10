@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\reviewGodotSaltoShellV2ScopedMaterialRecoveryWindows.ps1" %*
