param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0268"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-militia-intercept-preview-bridge-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0268-barrosan-watchpost-militia-intercept-preview-bridge"
$Verdict = if ($env:v0268_VERDICT) { $env:v0268_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:v0268_GODOT_PATH) { $env:v0268_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.268 capture Godot binary: $GodotPath" }

function Invoke-V0268RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.268 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.268 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.268"') { throw "Godot v0.268 $Label rendered capture did not dispatch v0.268 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.268 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.268 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.268 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0268/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0268/watchpost-militia-intercept-preview-bridge-runtime"

Invoke-V0268RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0268RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0268_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0268_default_runtime_unchanged_visible.png")

$Names = @(
 "v0268_watchpost_build_path_visible",
 "v0268_watchpost_complete_no_intel_no_intercept_preview_visible",
 "v0268_ashen_outside_zone_no_false_intercept_visible",
 "v0268_current_detection_no_militia_intercept_unavailable_visible",
 "v0268_current_detection_relay_intercept_unavailable_visible",
 "v0268_barracks_train_militia_advisory_still_visible",
 "v0268_militia_training_intercept_pending_visible",
 "v0268_current_detection_relay_intercept_pending_visible",
 "v0268_militia_ready_away_intercept_cannot_visible",
 "v0268_current_detection_relay_cannot_intercept_visible",
 "v0268_objective_move_defender_to_east_bridge_visible",
 "v0268_militia_holding_bridge_guarding_lane_visible",
 "v0268_current_detection_relay_guarding_lane_visible",
 "v0268_ashen_inside_intercept_envelope_visible",
 "v0268_current_detection_relay_intercept_ready_visible",
 "v0268_objective_intercept_ready_hold_bridge_visible",
 "v0268_no_damage_after_intercept_preview_visible",
 "v0268_no_enemy_slow_or_redirect_after_intercept_preview_visible",
 "v0268_threat_leaves_memory_cannot_intercept_visible",
 "v0268_threat_leaves_memory_guarding_last_seen_lane_visible",
 "v0268_last_seen_memory_marker_still_distinct_visible",
 "v0268_current_vs_memory_vs_position_vs_intercept_not_confused_visible",
 "v0268_watchpost_hud_no_train_militia_visible",
 "v0268_barracks_hud_no_watchpost_relay_card_visible",
 "v0268_existing_barracks_rebuild_path_still_valid_visible",
 "v0268_existing_barracks_still_trains_militia_visible",
 "v0268_no_intercept_before_watchpost_complete_visible",
 "v0268_no_intercept_ready_before_militia_holding_bridge_visible",
 "v0268_world_label_clutter_not_regressed_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0268BarrosanWatchpostMilitiaInterceptPreviewBridgePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.268 visual evidence assembly failed." }

node tools/godot/saltoV0268BarrosanWatchpostMilitiaInterceptPreviewBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.268 report assembly failed." }

Write-Output "PASS_V0268_BARROSAN_WATCHPOST_MILITIA_INTERCEPT_PREVIEW_BRIDGE_PACK_READY"
