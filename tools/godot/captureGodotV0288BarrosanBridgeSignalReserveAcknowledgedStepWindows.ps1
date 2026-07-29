param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0288"
$TrueDefaultRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0288"
$OptInRuntimeRoot = Join-Path $ArtifactRoot "bridge-signal-reserve-acknowledged-step-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0288-barrosan-bridge-signal-reserve-acknowledged-step"
$Verdict = if ($env:v0288_VERDICT) { $env:v0288_VERDICT } else { "PASS" }

Set-Location $RepoRoot
foreach ($Target in @($ArtifactRoot, $TrueDefaultRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    [System.IO.Directory]::Delete("\\?\$resolvedTarget", $true)
  }
}
New-Item -ItemType Directory -Force -Path $ArtifactRoot, $TrueDefaultRoot, $OptInRuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:v0288_GODOT_PATH) { $env:v0288_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.288 capture Godot binary: $GodotPath" }

function Invoke-v0288RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [string] $ExpectedCheckpoint, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.288 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.288 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($ExpectedCheckpoint -and $manifestRaw -notmatch ('"checkpoint"\s*:\s*"' + [regex]::Escape($ExpectedCheckpoint) + '"')) { throw "Godot v0.288 $Label capture did not dispatch $ExpectedCheckpoint." }
  if (-not $ExpectedCheckpoint -and $manifestRaw -match '"checkpoint"\s*:\s*"v0\.288"') { throw "Godot v0.288 $Label true-default capture accidentally dispatched the v0.288 review fixture." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.288 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -match '"enabled"\s*:\s*true') { throw "Godot v0.288 $Label rendered capture leaked the opt-in Barrosan runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.288 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$TrueDefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0288"
$OptInRuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0288/bridge-signal-reserve-acknowledged-step-runtime"

Invoke-v0288RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$TrueDefaultArgRoot") -ManifestPath (Join-Path $TrueDefaultRoot "screenshot-runtime-manifest.json") -Label "true default" -ExpectedCheckpoint "" -ExpectSkinEnabled $false
Invoke-v0288RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$OptInRuntimeArgRoot") -ManifestPath (Join-Path $OptInRuntimeRoot "screenshot-runtime-manifest.json") -Label "opt-in runtime" -ExpectedCheckpoint "v0.288" -ExpectSkinEnabled $true

Copy-Item (Join-Path $TrueDefaultRoot "screenshots\03_battle_default.png") (Join-Path $ManualRoot "02_v0288_true_default_runtime_baseline_no_fixture_no_opt_in.png")

$RuntimeCopies = @(
  @{ Source = "01_v0288_manual_fixture_baseline_clean_hud_visible.png"; Target = "04_v0288_manual_fixture_baseline_clean_hud.png" },
  @{ Source = "02_v0288_engage_available_before_click_visible.png"; Target = "05_v0288_engage_available_before_click.png" },
  @{ Source = "03_v0288_engage_armed_visible.png"; Target = "06_v0288_engage_armed.png" },
  @{ Source = "04_v0288_commit_engage_clicked_visible.png"; Target = "07_v0288_commit_engage_clicked.png" },
  @{ Source = "05_v0288_post_commit_pressure_checked_ashen_braced_visible.png"; Target = "08_v0288_post_commit_pressure_checked_ashen_braced.png" },
  @{ Source = "06_v0288_hold_line_available_after_commit_locked_visible.png"; Target = "09_v0288_hold_line_available_after_commit_locked.png" },
  @{ Source = "07_v0288_hold_line_clicked_visible.png"; Target = "10_v0288_hold_line_clicked.png" },
  @{ Source = "08_v0288_line_held_exactly_once_visible.png"; Target = "11_v0288_line_held_exactly_once.png" },
  @{ Source = "09_v0288_ashen_contained_exactly_once_visible.png"; Target = "12_v0288_ashen_contained_exactly_once.png" },
  @{ Source = "10_v0288_select_field_barracks_after_hold_line_visible.png"; Target = "13_v0288_select_field_barracks_after_hold_line.png" },
  @{ Source = "11_v0288_train_militia_available_reserve_slot_empty_visible.png"; Target = "14_v0288_train_militia_available_reserve_slot_empty.png" },
  @{ Source = "12_v0288_train_clicked_visible.png"; Target = "15_v0288_train_clicked.png" },
  @{ Source = "13_v0288_reserve_ready_exactly_once_visible.png"; Target = "16_v0288_reserve_ready_exactly_once.png" },
  @{ Source = "14_v0288_assign_to_bridge_available_visible.png"; Target = "17_v0288_assign_to_bridge_available.png" },
  @{ Source = "15_v0288_assign_clicked_visible.png"; Target = "18_v0288_assign_clicked.png" },
  @{ Source = "16_v0288_reserve_assigned_exactly_once_visible.png"; Target = "19_v0288_reserve_assigned_exactly_once.png" },
  @{ Source = "17_v0288_select_defender_after_reserve_assigned_visible.png"; Target = "20_v0288_select_defender_after_reserve_assigned.png" },
  @{ Source = "18_v0288_defender_card_signal_available_visible.png"; Target = "21_v0288_defender_card_signal_available.png" },
  @{ Source = "19_v0288_signal_clicked_visible.png"; Target = "22_v0288_signal_clicked.png" },
  @{ Source = "20_v0288_bridge_signal_sent_exactly_once_visible.png"; Target = "23_v0288_bridge_signal_sent_exactly_once.png" },
  @{ Source = "21_v0288_reserve_ack_exactly_once_visible.png"; Target = "24_v0288_reserve_ack_exactly_once.png" },
  @{ Source = "22_v0288_defender_card_reserve_acknowledged_visible.png"; Target = "25_v0288_defender_card_reserve_acknowledged.png" },
  @{ Source = "23_v0288_barracks_card_bridge_signal_received_visible.png"; Target = "26_v0288_barracks_card_bridge_signal_received.png" },
  @{ Source = "24_v0288_repeat_signal_no_duplicate_signal_ack_stack_visible.png"; Target = "27_v0288_repeat_signal_no_duplicate_signal_ack_stack.png" },
  @{ Source = "25_v0288_resources_unchanged_after_train_assign_signal_visible.png"; Target = "28_v0288_resources_unchanged_after_train_assign_signal.png" },
  @{ Source = "26_v0288_reserve_marker_no_movement_pathing_attack_deploy_behavior_visible.png"; Target = "29_v0288_reserve_marker_no_movement_pathing_attack_deploy_behavior.png" },
  @{ Source = "27_v0288_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_visible.png"; Target = "30_v0288_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal.png" },
  @{ Source = "28_v0288_field_barracks_no_engage_commit_hold_ashen_signal_visible.png"; Target = "31_v0288_field_barracks_no_engage_commit_hold_ashen_signal.png" },
  @{ Source = "29_v0288_clear_guard_settles_defender_contact_clean_after_signal_visible.png"; Target = "32_v0288_clear_guard_settles_defender_contact_clean_after_signal.png" },
  @{ Source = "30_v0288_reguard_clean_after_signal_no_auto_deploy_visible.png"; Target = "33_v0288_reguard_clean_after_signal_no_auto_deploy.png" },
  @{ Source = "31_v0288_no_projectile_damage_hp_loss_death_despawn_visible.png"; Target = "34_v0288_no_projectile_damage_hp_loss_death_despawn.png" }
)
foreach ($copy in $RuntimeCopies) {
  $sourcePath = Join-Path $OptInRuntimeRoot ("screenshots\" + $copy.Source)
  $targetPath = Join-Path $ManualRoot $copy.Target
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.288 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0288BarrosanBridgeSignalReserveAcknowledgedStepPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.288 visual evidence assembly failed." }

node tools/godot/saltoV0288BarrosanBridgeSignalReserveAcknowledgedStepTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--true-default-root=$($TrueDefaultRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.288 report assembly failed." }

Write-Output "PASS_v0288_BARROSAN_BRIDGE_SIGNAL_RESERVE_ACKNOWLEDGED_STEP_PACK_READY"
