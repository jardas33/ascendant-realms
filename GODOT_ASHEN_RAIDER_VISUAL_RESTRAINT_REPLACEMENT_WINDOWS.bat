@echo off
setlocal
cd /d "%~dp0"
call npm run godot:ashen-raider-replacement:derivatives:reproduce || exit /b 1
call npm run godot:ashen-raider-replacement:validate || exit /b 1
call npm run godot:ashen-raider-replacement:benchmark:headed || exit /b 1
call npm run godot:ashen-raider-replacement:audit || exit /b 1
echo v0.157 Ashen Raider visual-restraint replacement private comparator evidence is ready for human review.
