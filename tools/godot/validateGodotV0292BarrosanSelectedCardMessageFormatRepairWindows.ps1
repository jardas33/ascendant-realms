param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0292BarrosanSelectedCardMessageFormatRepairTool.mjs "--artifact-root=artifacts/desktop-spikes/godot-salto/v0292"
if ($LASTEXITCODE -ne 0) { throw "v0.292 selected-card message format validation failed" }
Write-Output "PASS_v0292_BARROSAN_SELECTED_CARD_MESSAGE_FORMAT_REPAIR_VALIDATION"
