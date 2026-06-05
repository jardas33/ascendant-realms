param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "captureGodotPlayerSliceWindows.ps1")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" player-slice-audit
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
