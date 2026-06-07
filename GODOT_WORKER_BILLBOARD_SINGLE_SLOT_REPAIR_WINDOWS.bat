@echo off
setlocal
pushd "%~dp0"
call npm run godot:worker-billboard-repair:derivatives:reproduce || exit /b 1
call npm run godot:worker-billboard-repair:validate || exit /b 1
call npm run godot:worker-billboard-repair:benchmark:headed || exit /b 1
call npm run godot:worker-billboard-repair:audit || exit /b 1
call npm run godot:worker-billboard-repair:capture || exit /b 1
popd
endlocal
