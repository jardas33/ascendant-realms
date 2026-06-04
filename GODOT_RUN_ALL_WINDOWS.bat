@echo off
setlocal
pushd "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\runGodotAll.ps1" %*
set EXITCODE=%ERRORLEVEL%
if not "%EXITCODE%"=="0" (
  popd
  exit /b %EXITCODE%
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\godot\validateGodotFreshCheckout.ps1"
set EXITCODE=%ERRORLEVEL%
popd
exit /b %EXITCODE%
