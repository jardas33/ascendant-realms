@echo off
setlocal
set "ROOT=%~dp0"
set "GODOT_EXE=%ASCENDANT_REALMS_GODOT%"
if not defined GODOT_EXE set "GODOT_EXE=D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe"
if not exist "%GODOT_EXE%" if defined GODOT set "GODOT_EXE=%GODOT%"
if not exist "%GODOT_EXE%" (
  echo Certified Godot 4.6.3 was not found. Set ASCENDANT_REALMS_GODOT or GODOT to the reviewed executable.
  exit /b 1
)
start "Ascendant Realms" "%GODOT_EXE%" --path "%ROOT%production\ascendant-realms-godot"
endlocal
