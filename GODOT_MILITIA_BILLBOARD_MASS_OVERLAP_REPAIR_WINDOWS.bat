@echo off
setlocal
pushd "%~dp0"
call npm run godot:militia-billboard-repair:derivatives:reproduce || exit /b 1
call npm run godot:militia-billboard-repair:validate || exit /b 1
call npm run godot:militia-billboard-repair:benchmark:headed || exit /b 1
call npm run godot:militia-billboard-repair:audit || exit /b 1
call npm run godot:militia-billboard-repair:capture || exit /b 1
popd
endlocal
