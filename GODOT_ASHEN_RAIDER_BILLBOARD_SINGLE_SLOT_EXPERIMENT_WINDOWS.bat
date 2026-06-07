@echo off
setlocal
cd /d "%~dp0"
call npm run godot:ashen-raider-billboard:fallback:reproduce || exit /b 1
call npm run godot:ashen-raider-billboard:validate || exit /b 1
call npm run godot:ashen-raider-billboard:benchmark:headed || exit /b 1
call npm run godot:ashen-raider-billboard:audit || exit /b 1
echo v0.156 Ashen Raider private comparator evidence is ready for human review.
