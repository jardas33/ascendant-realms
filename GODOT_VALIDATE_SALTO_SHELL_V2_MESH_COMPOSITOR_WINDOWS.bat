@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\validateGodotSaltoShellV2MeshCompositorWindows.ps1" %*
