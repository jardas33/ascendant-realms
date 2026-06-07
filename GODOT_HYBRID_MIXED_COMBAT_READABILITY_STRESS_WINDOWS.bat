@echo off
setlocal
cd /d "%~dp0"

call npm run godot:hybrid-mixed-combat:validate
if errorlevel 1 goto fail

call npm run godot:hybrid-mixed-combat:audit
if errorlevel 1 goto fail

call npm run godot:hybrid-mixed-combat:benchmark:headed
if errorlevel 1 goto fail

call npm run godot:hybrid-mixed-combat:capture
if errorlevel 1 goto fail

call npm run godot:hybrid-mixed-combat:audit
if errorlevel 1 goto fail

echo PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_WORKFLOW
exit /b 0

:fail
echo FAIL_V0158_HYBRID_MIXED_COMBAT_STRESS_WORKFLOW
exit /b 1
