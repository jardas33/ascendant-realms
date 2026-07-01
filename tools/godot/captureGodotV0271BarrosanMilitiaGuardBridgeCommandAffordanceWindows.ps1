param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0271"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "militia-guard-bridge-command-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0271-barrosan-militia-guard-bridge-command-affordance"
$Verdict = if ($env:v0271_VERDICT) { $env:v0271_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:v0271_GODOT_PATH) { $env:v0271_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.271 capture Godot binary: $GodotPath" }

function Invoke-V0271RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.271 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.271 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.271"') { throw "Godot v0.271 $Label rendered capture did not dispatch v0.271 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.271 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.271 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.271 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0271/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0271/militia-guard-bridge-command-runtime"

Invoke-V0271RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0271RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0271_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0271_default_runtime_unchanged_visible.png")

$Names = @(
 "v0271_watchpost_build_path_visible",
 "v0271_watchpost_complete_no_intel_no_contact_visible",
 "v0271_barracks_train_militia_visible",
 "v0271_militia_training_guard_unavailable_visible",
 "v0271_militia_ready_guard_available_visible",
 "v0271_guard_button_visible_on_militia_not_watchpost_visible",
 "v0271_guard_order_pending_militia_away_visible",
 "v0271_no_auto_move_after_guard_order_visible",
 "v0271_watchpost_advises_move_to_bridge_visible",
 "v0271_militia_near_bridge_guard_confirmed_visible",
 "v0271_guard_marker_east_bridge_visible",
 "v0271_defender_position_holding_from_guard_order_visible",
 "v0271_intercept_preview_requires_guard_order_visible",
 "v0271_current_detection_no_guard_no_contact_visible",
 "v0271_current_detection_guard_pending_no_contact_visible",
 "v0271_current_detection_guard_holding_contact_armed_visible",
 "v0271_intercept_ready_integrity_100_visible",
 "v0271_first_contact_feedback_pulse_visible",
 "v0271_first_contact_integrity_90_visible",
 "v0271_contact_resolved_cooldown_locked_visible",
 "v0271_no_repeated_damage_below_90_visible",
 "v0271_overlap_continues_integrity_still_90_visible",
 "v0271_threat_leaves_memory_integrity_90_visible",
 "v0271_memory_only_no_new_contact_damage_visible",
 "v0271_no_enemy_death_or_despawn_visible",
 "v0271_no_enemy_slow_stop_redirect_visible",
 "v0271_no_militia_hp_loss_visible",
 "v0271_no_watchpost_hp_loss_visible",
 "v0271_no_watchpost_attack_projectile_tower_visible",
 "v0271_watchpost_hud_advisory_only_no_train_no_guard_action_visible",
 "v0271_barracks_hud_train_militia_no_full_relay_visible",
 "v0271_militia_hud_guard_order_contact_resolved_visible",
 "v0271_minimap_guard_pending_indicator_visible",
 "v0271_minimap_guard_holding_indicator_visible",
 "v0271_minimap_contact_ping_current_only_visible",
 "v0271_minimap_memory_no_contact_ping_visible",
 "v0271_label_declutter_guard_pending_visible",
 "v0271_label_declutter_guard_holding_visible",
 "v0271_label_declutter_first_contact_visible",
 "v0271_existing_barracks_rebuild_path_still_valid_visible",
 "v0271_existing_barracks_still_trains_militia_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0271BarrosanMilitiaGuardBridgeCommandAffordancePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.271 visual evidence assembly failed." }

node tools/godot/saltoV0271BarrosanMilitiaGuardBridgeCommandAffordanceTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.271 report assembly failed." }

Write-Output "PASS_V0271_BARROSAN_MILITIA_GUARD_BRIDGE_COMMAND_AFFORDANCE_PACK_READY"
