param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
node tools/godot/saltoV0259BarrosanUiStateInvariantTool.mjs validation "--artifact-root=artifacts/desktop-spikes/godot-salto/v0259"
if ($LASTEXITCODE -ne 0) { throw "v0.259 UI state invariant validation failed." }
Write-Output "PASS_V0259_BARROSAN_UI_STATE_INVARIANT_VALIDATION"
