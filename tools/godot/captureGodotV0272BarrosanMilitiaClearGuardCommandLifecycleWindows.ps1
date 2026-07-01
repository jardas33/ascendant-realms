param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0272"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "militia-clear-guard-command-lifecycle-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0272-barrosan-militia-clear-guard-command-lifecycle"
$Verdict = if ($env:v0272_VERDICT) { $env:v0272_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:v0272_GODOT_PATH) { $env:v0272_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.272 capture Godot binary: $GodotPath" }

function Invoke-v0272RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.272 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.272 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.272"') { throw "Godot v0.272 $Label rendered capture did not dispatch v0.272 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.272 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.272 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.272 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0272/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0272/militia-clear-guard-command-lifecycle-runtime"

Invoke-v0272RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-v0272RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0272_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0272_default_runtime_unchanged_visible.png")

$Names = @(
 "v0272_watchpost_build_path_visible",
 "v0272_watchpost_complete_no_intel_no_contact_visible",
 "v0272_barracks_train_militia_visible",
 "v0272_militia_training_guard_unavailable_visible",
 "v0272_militia_ready_guard_available_visible",
 "v0272_guard_button_visible_on_militia_only_visible",
 "v0272_guard_order_pending_clear_guard_button_visible",
 "v0272_clear_pending_guard_no_auto_move_visible",
 "v0272_guard_cleared_marker_removed_visible",
 "v0272_guard_cleared_minimap_indicator_removed_visible",
 "v0272_current_detection_no_guard_no_contact_visible",
 "v0272_guard_pending_no_contact_visible",
 "v0272_guard_pending_then_cleared_no_contact_visible",
 "v0272_guard_holding_clear_guard_button_visible",
 "v0272_guard_holding_contact_armed_visible",
 "v0272_clear_holding_before_contact_blocks_contact_visible",
 "v0272_guard_reissued_after_clear_pending_visible",
 "v0272_guard_reissued_holding_intercept_ready_visible",
 "v0272_first_contact_feedback_pulse_visible",
 "v0272_first_contact_integrity_90_visible",
 "v0272_contact_resolved_cooldown_locked_visible",
 "v0272_clear_guard_after_contact_pressure_still_90_visible",
 "v0272_no_repeated_damage_after_clear_and_reguard_visible",
 "v0272_overlap_continues_integrity_still_90_visible",
 "v0272_threat_leaves_memory_integrity_90_visible",
 "v0272_memory_only_no_new_contact_damage_visible",
 "v0272_no_enemy_death_or_despawn_visible",
 "v0272_no_enemy_slow_stop_redirect_visible",
 "v0272_no_militia_hp_loss_visible",
 "v0272_no_watchpost_hp_loss_visible",
 "v0272_no_watchpost_attack_projectile_tower_visible",
 "v0272_watchpost_hud_advisory_only_no_train_no_guard_no_clear_visible",
 "v0272_watchpost_relay_guard_cleared_message_visible",
 "v0272_barracks_hud_train_militia_no_full_relay_visible",
 "v0272_militia_hud_guard_available_after_clear_visible",
 "v0272_militia_hud_resolved_cooldown_after_contact_visible",
 "v0272_minimap_guard_pending_indicator_visible",
 "v0272_minimap_guard_holding_indicator_visible",
 "v0272_minimap_guard_cleared_no_indicator_visible",
 "v0272_minimap_contact_ping_current_only_visible",
 "v0272_minimap_memory_no_contact_ping_visible",
 "v0272_label_declutter_guard_cleared_visible",
 "v0272_label_declutter_first_contact_visible",
 "v0272_existing_barracks_rebuild_path_still_valid_visible",
 "v0272_existing_barracks_still_trains_militia_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0272BarrosanMilitiaClearGuardCommandLifecyclePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.272 visual evidence assembly failed." }

node tools/godot/saltoV0272BarrosanMilitiaClearGuardCommandLifecycleTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.272 report assembly failed." }

Write-Output "PASS_V0272_BARROSAN_MILITIA_CLEAR_GUARD_COMMAND_LIFECYCLE_PACK_READY"
