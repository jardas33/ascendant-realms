param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0269BarrosanMilitiaFirstContactMicroConsequenceTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0269"
if ($LASTEXITCODE -ne 0) { throw "v0.269 Barrosan Militia First Contact Micro-Consequence validation failed." }
Write-Output "PASS_V0269_BARROSAN_MILITIA_FIRST_CONTACT_MICRO_CONSEQUENCE_VALIDATION"
