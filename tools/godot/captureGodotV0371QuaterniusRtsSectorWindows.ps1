param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$GodotExe = if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { $env:GODOT_BIN } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path $GodotExe)) { throw "Missing Godot executable: $GodotExe" }
Set-Location $RepoRoot
$ArtifactRoot = Join-Path $RepoRoot "artifacts\runtime\v0371"
$ReviewRoot = Join-Path $RepoRoot "artifacts\manual-review\v0371-first-cohesive-quaternius-rts-sector"
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
New-Item -ItemType Directory -Force -Path $ReviewRoot | Out-Null
$ArtifactArg = "artifacts/runtime/v0371"
$process = Start-Process -FilePath $GodotExe -ArgumentList @("--path", "desktop-spikes/godot-salto", "--", "--v0371-capture", "--artifact-root=$ArtifactArg") -Wait -PassThru
if ($process.ExitCode -ne 0) { exit $process.ExitCode }
$names = @("01_OPENING_GAMEPLAY.png","02_WORKER_GATHERING_GOLD.png","03_FIELD_BARRACKS_CONSTRUCTION.png","04_COMPLETED_BARRACKS_RECRUITMENT.png","05_MILITIA_CROSSING_BRIDGE.png","06_COMBAT_AT_HOSTILE_CAMP.png","07_VICTORY_STATE.png")
foreach ($name in $names) {
  $source = Join-Path $RepoRoot "desktop-spikes\godot-salto\artifacts\runtime\v0371\$name"
  if (-not (Test-Path $source)) { throw "Missing capture: $source" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $ReviewRoot $name) -Force
}
node tools/godot/saltoV0371QuaterniusRtsSectorTool.mjs pack
