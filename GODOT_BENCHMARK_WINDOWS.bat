@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\runGodotBenchmark.ps1" %*
