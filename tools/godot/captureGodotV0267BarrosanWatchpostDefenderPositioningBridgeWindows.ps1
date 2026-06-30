param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0267"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-defender-positioning-bridge-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0267-barrosan-watchpost-defender-positioning-bridge"
$Verdict = if ($env:v0267_VERDICT) { $env:v0267_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:v0267_GODOT_PATH) { $env:v0267_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.267 capture Godot binary: $GodotPath" }

function Invoke-V0267RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.267 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.267 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.267"') { throw "Godot v0.267 $Label rendered capture did not dispatch v0.267 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.267 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.267 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.267 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0267/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0267/watchpost-defender-positioning-bridge-runtime"

Invoke-V0267RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0267RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0267_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0267_default_runtime_unchanged_visible.png")

$Names = @(
 "v0267_watchpost_build_path_visible",
 "v0267_watchpost_complete_no_intel_no_position_alarm_visible",
 "v0267_ashen_outside_zone_no_false_positive_no_position_alarm_visible",
 "v0267_current_detection_no_militia_position_none_visible",
 "v0267_current_detection_relay_position_none_visible",
 "v0267_barracks_train_militia_advisory_still_visible",
 "v0267_militia_training_position_pending_visible",
 "v0267_current_detection_relay_position_pending_visible",
 "v0267_militia_ready_away_from_bridge_visible",
 "v0267_current_detection_relay_ready_not_in_position_visible",
 "v0267_objective_move_defender_to_east_bridge_visible",
 "v0267_militia_moved_near_bridge_visible",
 "v0267_current_detection_relay_holding_east_bridge_visible",
 "v0267_objective_defender_in_position_visible",
 "v0267_threat_leaves_memory_position_not_in_position_visible",
 "v0267_threat_leaves_memory_position_holding_bridge_visible",
 "v0267_last_seen_memory_marker_still_distinct_visible",
 "v0267_current_vs_memory_vs_position_not_confused_visible",
 "v0267_watchpost_hud_no_train_militia_visible",
 "v0267_barracks_hud_no_watchpost_relay_card_visible",
 "v0267_existing_barracks_rebuild_path_still_valid_visible",
 "v0267_existing_barracks_still_trains_militia_visible",
 "v0267_no_position_before_watchpost_complete_visible",
 "v0267_no_position_holding_before_militia_near_bridge_visible",
 "v0267_world_label_clutter_not_regressed_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0267BarrosanWatchpostDefenderPositioningBridgePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.267 visual evidence assembly failed." }

node tools/godot/saltoV0267BarrosanWatchpostDefenderPositioningBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.267 report assembly failed." }

Write-Output "PASS_V0267_BARROSAN_WATCHPOST_DEFENDER_POSITIONING_BRIDGE_PACK_READY"
