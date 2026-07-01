param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0275"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "post-contact-label-arbitration-hud-first-readability-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0275-barrosan-post-contact-label-arbitration-hud-first-readability"
$Verdict = if ($env:v0275_VERDICT) { $env:v0275_VERDICT } else { "PARTIAL" }

Set-Location $RepoRoot
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    [System.IO.Directory]::Delete("\\?\$resolvedTarget", $true)
  }
}
New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:v0275_GODOT_PATH) { $env:v0275_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.275 capture Godot binary: $GodotPath" }

function Invoke-v0275RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.275 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.275 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.275"') { throw "Godot v0.275 $Label rendered capture did not dispatch v0.275 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.275 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.275 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.275 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0275/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0275/post-contact-label-arbitration-hud-first-readability-runtime"
Invoke-v0275RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") -Label "default" -ExpectSkinEnabled $false
Invoke-v0275RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") -Label "runtime" -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0275_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0275_default_runtime_unchanged_visible.png")

$Names = @(
 "v0275_watchpost_build_path_visible",
 "v0275_watchpost_complete_no_intel_no_contact_visible",
 "v0275_barracks_train_militia_visible",
 "v0275_militia_training_guard_unavailable_visible",
 "v0275_militia_ready_guard_available_visible",
 "v0275_guard_order_pending_label_clean_visible",
 "v0275_clear_pending_guard_blocks_contact_visible",
 "v0275_guard_reissued_after_clear_visible",
 "v0275_guard_holding_intercept_ready_single_priority_label_visible",
 "v0275_current_detection_no_guard_no_contact_label_clean_visible",
 "v0275_guard_pending_no_contact_label_clean_visible",
 "v0275_guard_holding_contact_armed_label_clean_visible",
 "v0275_first_contact_feedback_suppresses_lower_labels_visible",
 "v0275_first_contact_integrity_90_visible",
 "v0275_contact_resolved_single_label_visible",
 "v0275_contact_resolved_cooldown_locked_visible",
 "v0275_bridge_held_single_world_label_visible",
 "v0275_bridge_held_no_defender_position_overlap_visible",
 "v0275_engagement_contained_single_priority_label_visible",
 "v0275_engagement_line_static_not_projectile_visible",
 "v0275_militia_hud_engagement_contained_no_attack_visible",
 "v0275_watchpost_hud_engagement_observed_advisory_only_visible",
 "v0275_minimap_engagement_indicator_distinct_visible",
 "v0275_contact_ping_not_active_after_resolved_visible",
 "v0275_bridge_held_and_engagement_no_repeated_damage_visible",
 "v0275_clear_guard_after_contact_label_clean_visible",
 "v0275_engagement_marker_removed_after_clear_visible",
 "v0275_minimap_engagement_indicator_removed_after_clear_visible",
 "v0275_pressure_still_90_after_clear_visible",
 "v0275_reguard_after_contact_label_clean_visible",
 "v0275_reguard_after_contact_no_first_contact_relabel_visible",
 "v0275_no_repeated_damage_after_reguard_visible",
 "v0275_overlap_continues_integrity_still_90_visible",
 "v0275_memory_only_no_new_contact_damage_label_clean_visible",
 "v0275_outside_zone_no_false_contact_label_clean_visible",
 "v0275_no_enemy_death_or_despawn_visible",
 "v0275_no_enemy_slow_stop_redirect_visible",
 "v0275_no_militia_hp_loss_visible",
 "v0275_no_watchpost_hp_loss_visible",
 "v0275_no_watchpost_attack_projectile_tower_visible",
 "v0275_watchpost_no_train_no_guard_no_clear_no_brace_no_engagement_action_visible",
 "v0275_barracks_hud_train_militia_no_full_relay_visible",
 "v0275_militia_hud_no_ranged_attack_no_projectile_visible",
 "v0275_label_priority_table_debug_visible",
 "v0275_label_declutter_first_contact_visible",
 "v0275_label_declutter_contact_resolved_visible",
 "v0275_label_declutter_bridge_held_visible",
 "v0275_label_declutter_engagement_contained_visible",
 "v0275_label_declutter_after_clear_visible",
 "v0275_existing_barracks_rebuild_path_still_valid_visible",
 "v0275_existing_barracks_still_trains_militia_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  $sourcePath = Join-Path $RuntimeRoot "screenshots\$source"
  $targetPath = Join-Path $ManualRoot $target
  $deadline = (Get-Date).AddSeconds(10)
  while (-not [System.IO.File]::Exists("\\?\$sourcePath") -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 100 }
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.275 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0275BarrosanPostContactLabelArbitrationHudFirstReadabilityPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.275 visual evidence assembly failed." }

node tools/godot/saltoV0275BarrosanPostContactLabelArbitrationHudFirstReadabilityTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.275 report assembly failed." }

Write-Output "PASS_V0275_BARROSAN_POST_CONTACT_LABEL_ARBITRATION_HUD_FIRST_READABILITY_PACK_READY"
