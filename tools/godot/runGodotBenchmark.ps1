param(
  [switch]$ScorecardOnly
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotExe = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) {
  $env:GODOT_BIN
} elseif (Test-Path (Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe")) {
  Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe"
} else {
  $null
}
Set-Location $RepoRoot

if ($ScorecardOnly) {
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" scorecard
  exit 0
}

node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" validate
if ($GodotExe) {
  & $GodotExe --headless --quit-after 60 --path "desktop-spikes/godot-salto" -- --run-benchmark
  $GodotExitCode = $LASTEXITCODE
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" benchmark
  if ($GodotExitCode -ne 0) {
    exit $GodotExitCode
  }
}
else {
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" benchmark
}
