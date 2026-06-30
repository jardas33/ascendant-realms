param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0269"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "militia-first-contact-micro-consequence-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0269-barrosan-militia-first-contact-micro-consequence"
$Verdict = if ($env:v0269_VERDICT) { $env:v0269_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:v0269_GODOT_PATH) { $env:v0269_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.269 capture Godot binary: $GodotPath" }

function Invoke-V0269RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.269 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.269 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.269"') { throw "Godot v0.269 $Label rendered capture did not dispatch v0.269 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.269 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.269 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.269 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0269/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0269/militia-first-contact-micro-consequence-runtime"

Invoke-V0269RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0269RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0269_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0269_default_runtime_unchanged_visible.png")

$Names = @(
 "v0269_watchpost_build_path_visible",
 "v0269_watchpost_complete_no_intel_no_contact_visible",
 "v0269_ashen_outside_zone_no_contact_visible",
 "v0269_current_detection_no_militia_contact_unavailable_visible",
 "v0269_current_detection_militia_training_contact_pending_visible",
 "v0269_militia_ready_away_contact_unavailable_visible",
 "v0269_militia_holding_guarding_lane_no_contact_visible",
 "v0269_intercept_ready_pre_contact_integrity_100_visible",
 "v0269_contact_armed_no_damage_yet_visible",
 "v0269_first_contact_engaged_integrity_90_visible",
 "v0269_no_repeated_damage_below_90_visible",
 "v0269_no_enemy_despawn_after_contact_visible",
 "v0269_no_militia_hp_loss_after_contact_visible",
 "v0269_no_watchpost_damage_or_attack_visible",
 "v0269_no_projectile_or_tower_attack_visible",
 "v0269_no_enemy_slow_or_redirect_visible",
 "v0269_threat_leaves_after_contact_memory_integrity_90_visible",
 "v0269_memory_only_no_new_contact_damage_visible",
 "v0269_last_seen_memory_marker_distinct_visible",
 "v0269_current_vs_memory_vs_position_vs_intercept_vs_contact_not_confused_visible",
 "v0269_watchpost_hud_contact_state_no_train_militia_visible",
 "v0269_barracks_hud_train_militia_no_watchpost_relay_visible",
 "v0269_militia_selected_contact_state_visible",
 "v0269_minimap_current_detection_contact_ping_visible",
 "v0269_minimap_memory_no_contact_ping_visible",
 "v0269_no_contact_before_watchpost_complete_visible",
 "v0269_no_contact_before_militia_holding_bridge_visible",
 "v0269_no_contact_when_ashen_only_outside_range_visible",
 "v0269_label_declutter_intercept_ready_visible",
 "v0269_label_declutter_contact_engaged_visible",
 "v0269_existing_barracks_rebuild_path_still_valid_visible",
 "v0269_existing_barracks_still_trains_militia_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0269BarrosanMilitiaFirstContactMicroConsequencePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.269 visual evidence assembly failed." }

node tools/godot/saltoV0269BarrosanMilitiaFirstContactMicroConsequenceTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.269 report assembly failed." }

Write-Output "PASS_V0269_BARROSAN_MILITIA_FIRST_CONTACT_MICRO_CONSEQUENCE_PACK_READY"
