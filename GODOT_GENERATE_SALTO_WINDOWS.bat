@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\generateGodotSaltoScene.ps1" %*
