@echo off
setlocal
pushd "%~dp0"
call npm run godot:barracks-material:fallback:reproduce || exit /b 1
call npm run godot:barracks-material:derivatives:reproduce || exit /b 1
call npm run godot:barracks-material:validate || exit /b 1
call npm run godot:barracks-material:benchmark:headed || exit /b 1
call npm run godot:barracks-material:audit || exit /b 1
call npm run godot:barracks-material:capture || exit /b 1
popd
endlocal
