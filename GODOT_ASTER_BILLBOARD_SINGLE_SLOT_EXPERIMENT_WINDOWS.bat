@echo off
setlocal
pushd "%~dp0"
call npm run godot:aster-billboard:metadata || exit /b 1
call npm run godot:aster-billboard:fallback:reproduce || exit /b 1
call npm run godot:aster-billboard:validate || exit /b 1
call npm run godot:aster-billboard:benchmark:headed || exit /b 1
call npm run godot:aster-billboard:audit || exit /b 1
call npm run godot:aster-billboard:capture || exit /b 1
popd
endlocal
