@echo off
setlocal
pushd "%~dp0"
call npm run godot:barracks-material-seam-repair:derivatives:reproduce || exit /b 1
call npm run godot:barracks-material-seam-repair:validate || exit /b 1
call npm run godot:barracks-material-seam-repair:benchmark:headed || exit /b 1
call npm run godot:barracks-material-seam-repair:audit || exit /b 1
call npm run godot:barracks-material-seam-repair:capture || exit /b 1
popd
endlocal
