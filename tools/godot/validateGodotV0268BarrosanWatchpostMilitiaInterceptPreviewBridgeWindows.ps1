param()
$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path (Join-Path $PSScriptRoot "..\.."))
node tools/godot/saltoV0268BarrosanWatchpostMilitiaInterceptPreviewBridgeTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0268"
if ($LASTEXITCODE -ne 0) { throw "v0.268 Barrosan Watchpost Militia Intercept Preview Bridge validation failed." }
Write-Output "PASS_V0268_BARROSAN_WATCHPOST_MILITIA_INTERCEPT_PREVIEW_BRIDGE_VALIDATION"
