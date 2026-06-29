param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0266"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-defender-readiness-bridge-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0266-barrosan-watchpost-defender-readiness-bridge"
$Verdict = if ($env:v0266_VERDICT) { $env:v0266_VERDICT } else { "PARTIAL" }

Set-Location $RepoRoot

foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) {
      throw "Refusing to remove path outside artifacts: $resolvedTarget"
    }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}

New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:v0266_GODOT_PATH) { $env:v0266_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.266 capture Godot binary: $GodotPath" }

function Invoke-V0266RenderedCapture {
  param(
    [string[]] $Arguments,
    [string] $ManifestPath,
    [string] $Label,
    [bool] $ExpectSkinEnabled
  )
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.266 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.266 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.266"') { throw "Godot v0.266 $Label rendered capture did not dispatch v0.266 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.266 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.266 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.266 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0266/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0266/watchpost-defender-readiness-bridge-runtime"

Invoke-V0266RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0266RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0266_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0266_default_runtime_unchanged_visible.png")

$Names = @(
 "v0266_watchpost_build_path_visible",
 "v0266_complete_no_intel_no_readiness_alarm_visible",
 "v0266_outside_no_false_positive_no_readiness_alarm_visible",
 "v0266_current_detection_no_defender_readiness_visible",
 "v0266_current_detection_train_militia_objective_visible",
 "v0266_current_detection_relay_readiness_none_visible",
 "v0266_barracks_selected_current_detection_train_militia_advisory_visible",
 "v0266_militia_training_started_from_barracks_visible",
 "v0266_current_detection_relay_readiness_training_visible",
 "v0266_objective_militia_training_underway_visible",
 "v0266_militia_ready_after_existing_training_visible",
 "v0266_current_detection_relay_readiness_ready_visible",
 "v0266_threat_leaves_memory_readiness_ready_visible",
 "v0266_last_seen_memory_readiness_none_path_visible",
 "v0266_last_seen_memory_readiness_training_path_visible",
 "v0266_last_seen_memory_marker_distinct_visible",
 "v0266_current_vs_memory_readiness_not_confused_visible",
 "v0266_watchpost_hud_no_train_militia_visible",
 "v0266_barracks_hud_no_watchpost_relay_card_visible",
 "v0266_existing_barracks_rebuild_path_valid_visible",
 "v0266_existing_barracks_still_trains_militia_visible",
 "v0266_no_detection_readiness_before_watchpost_complete_visible",
 "v0266_world_label_clutter_not_regressed_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0266BarrosanWatchpostDefenderReadinessBridgePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.266 visual evidence assembly failed." }

node tools/godot/saltoV0266BarrosanWatchpostDefenderReadinessBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.266 report assembly failed." }

Write-Output "PASS_V0266_BARROSAN_WATCHPOST_DEFENDER_READINESS_BRIDGE_PACK_READY"

