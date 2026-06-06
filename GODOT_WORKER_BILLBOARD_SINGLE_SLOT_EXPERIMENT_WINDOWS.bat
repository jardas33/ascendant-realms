@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\godot\runGodotWorkerBillboardBenchmarkWindows.ps1"
if errorlevel 1 exit /b %errorlevel%
echo.
echo v0.147 Worker billboard single-slot comparator evidence is ready under artifacts\desktop-spikes\godot-salto\v0147\evidence
