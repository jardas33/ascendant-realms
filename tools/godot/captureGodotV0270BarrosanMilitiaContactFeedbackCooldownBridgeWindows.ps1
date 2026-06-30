param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0270"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "militia-contact-feedback-cooldown-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0270-barrosan-militia-contact-feedback-cooldown-bridge"
$Verdict = if ($env:v0270_VERDICT) { $env:v0270_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:v0270_GODOT_PATH) { $env:v0270_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.270 capture Godot binary: $GodotPath" }

function Invoke-V0270RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.270 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.270 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.270"') { throw "Godot v0.270 $Label rendered capture did not dispatch v0.270 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.270 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.270 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.270 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0270/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0270/militia-contact-feedback-cooldown-runtime"

Invoke-V0270RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0270RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0270_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0270_default_runtime_unchanged_visible.png")

$Names = @(
 "v0270_watchpost_build_path_visible",
 "v0270_watchpost_complete_no_intel_no_contact_visible",
 "v0270_ashen_outside_zone_no_contact_visible",
 "v0270_current_detection_no_militia_contact_unavailable_visible",
 "v0270_militia_training_contact_pending_visible",
 "v0270_militia_ready_away_contact_unavailable_visible",
 "v0270_militia_holding_guarding_lane_integrity_100_visible",
 "v0270_intercept_ready_integrity_100_visible",
 "v0270_contact_armed_no_damage_yet_visible",
 "v0270_first_contact_feedback_pulse_visible",
 "v0270_first_contact_integrity_90_visible",
 "v0270_contact_resolved_cooldown_locked_visible",
 "v0270_no_repeated_damage_below_90_visible",
 "v0270_overlap_continues_integrity_still_90_visible",
 "v0270_no_enemy_death_or_despawn_visible",
 "v0270_no_enemy_slow_stop_redirect_visible",
 "v0270_no_militia_hp_loss_visible",
 "v0270_no_watchpost_hp_loss_visible",
 "v0270_no_watchpost_attack_damage_projectile_visible",
 "v0270_no_tower_behavior_visible",
 "v0270_threat_leaves_contact_ended_memory_visible",
 "v0270_memory_only_no_new_contact_damage_visible",
 "v0270_last_seen_integrity_90_visible",
 "v0270_minimap_contact_ping_current_only_visible",
 "v0270_minimap_memory_no_contact_ping_visible",
 "v0270_watchpost_hud_contact_cooldown_no_train_militia_visible",
 "v0270_barracks_hud_train_militia_no_full_relay_visible",
 "v0270_militia_selected_contact_resolved_visible",
 "v0270_label_declutter_pre_contact_visible",
 "v0270_label_declutter_first_contact_visible",
 "v0270_label_declutter_contact_resolved_visible",
 "v0270_existing_barracks_rebuild_path_still_valid_visible",
 "v0270_existing_barracks_still_trains_militia_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0270BarrosanMilitiaContactFeedbackCooldownBridgePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.270 visual evidence assembly failed." }

node tools/godot/saltoV0270BarrosanMilitiaContactFeedbackCooldownBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.270 report assembly failed." }

Write-Output "PASS_V0270_BARROSAN_MILITIA_CONTACT_FEEDBACK_COOLDOWN_BRIDGE_PACK_READY"
