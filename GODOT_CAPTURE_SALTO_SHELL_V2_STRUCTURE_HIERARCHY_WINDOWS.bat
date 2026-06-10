@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\captureGodotSaltoShellV2StructureHierarchyWindows.ps1" %*
