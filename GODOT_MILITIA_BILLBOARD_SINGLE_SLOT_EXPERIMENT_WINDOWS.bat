@echo off
setlocal
pushd "%~dp0"
call npm run godot:militia-billboard:metadata || exit /b 1
call npm run godot:militia-billboard:fallback:reproduce || exit /b 1
call npm run godot:militia-billboard:validate || exit /b 1
call npm run godot:militia-billboard:benchmark:headed || exit /b 1
call npm run godot:militia-billboard:audit || exit /b 1
call npm run godot:militia-billboard:capture || exit /b 1
popd
endlocal
