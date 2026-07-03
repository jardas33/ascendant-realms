param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0284BarrosanHudTextLayoutRepairTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0284" "--true-default-root=artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0284"
if ($LASTEXITCODE -ne 0) { throw "FAIL_V0284_BARROSAN_HUD_TEXT_LAYOUT_REPAIR_VALIDATION" }
Write-Output "PASS_V0284_BARROSAN_HUD_TEXT_LAYOUT_REPAIR_VALIDATION"
