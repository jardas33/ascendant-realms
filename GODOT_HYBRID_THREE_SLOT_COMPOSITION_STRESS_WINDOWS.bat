@echo off
setlocal
pushd "%~dp0"
call npm run godot:hybrid-three-slot-composition:validate || exit /b 1
call npm run godot:hybrid-three-slot-composition:benchmark:headed || exit /b 1
call npm run godot:hybrid-three-slot-composition:audit || exit /b 1
call npm run godot:hybrid-three-slot-composition:capture || exit /b 1
popd
endlocal
