param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0290"
$TrueDefaultRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0290"
$OptInRuntimeRoot = Join-Path $ArtifactRoot "reserve-deployment-approval-gate-step-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0290-barrosan-reserve-deployment-approval-gate-step"
$Verdict = if ($env:v0290_VERDICT) { $env:v0290_VERDICT } else { "PASS" }

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

$GodotPath = if ($env:v0290_GODOT_PATH) { $env:v0290_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.290 capture Godot binary: $GodotPath" }

function Invoke-v0290RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [string] $ExpectedCheckpoint, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.290 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.290 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($ExpectedCheckpoint -and $manifestRaw -notmatch ('"checkpoint"\s*:\s*"' + [regex]::Escape($ExpectedCheckpoint) + '"')) { throw "Godot v0.290 $Label capture did not dispatch $ExpectedCheckpoint." }
  if (-not $ExpectedCheckpoint -and $manifestRaw -match '"checkpoint"\s*:\s*"v0\.290"') { throw "Godot v0.290 $Label true-default capture accidentally dispatched the v0.290 review fixture." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.290 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -match '"enabled"\s*:\s*true') { throw "Godot v0.290 $Label rendered capture leaked the opt-in Barrosan runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.290 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$TrueDefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0290"
$OptInRuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0290/reserve-deployment-approval-gate-step-runtime"
Invoke-v0290RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$TrueDefaultArgRoot") -ManifestPath (Join-Path $TrueDefaultRoot "screenshot-runtime-manifest.json") -Label "true default" -ExpectedCheckpoint "" -ExpectSkinEnabled $false
Invoke-v0290RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$OptInRuntimeArgRoot") -ManifestPath (Join-Path $OptInRuntimeRoot "screenshot-runtime-manifest.json") -Label "opt-in runtime" -ExpectedCheckpoint "v0.290" -ExpectSkinEnabled $true

Copy-Item (Join-Path $TrueDefaultRoot "screenshots\03_battle_default.png") (Join-Path $ManualRoot "02_v0290_true_default_runtime_baseline_no_fixture_no_opt_in.png")
$RuntimeTargets = @(
"04_manual_fixture_baseline_clean_hud", "05_engage_available_before_click", "06_engage_armed", "07_commit_engage_clicked", "08_post_commit_pressure_checked_ashen_braced", "09_hold_line_available_after_commit_locked", "10_hold_line_clicked", "11_line_held_exactly_once", "12_ashen_contained_exactly_once", "13_select_field_barracks_after_hold_line", "14_train_militia_available_reserve_slot_empty", "15_train_clicked", "16_reserve_ready_exactly_once", "17_assign_to_bridge_available", "18_assign_clicked", "19_reserve_assigned_exactly_once", "20_select_defender_after_reserve_assigned", "21_signal_available", "22_signal_clicked", "23_bridge_signal_sent_exactly_once", "24_signal_sent_exactly_once", "25_reserve_ack_exactly_once", "26_select_field_barracks_after_reserve_ack", "27_prepare_support_available", "28_prepare_clicked", "29_support_order_ready_exactly_once", "30_order_ready_exactly_once", "31_select_field_barracks_after_support_order_ready", "32_approve_available", "33_approve_clicked", "34_deployment_approved_exactly_once", "35_approved_exactly_once", "36_barracks_card_awaiting_launch_order", "37_defender_card_support_approved_awaiting_launch", "38_repeat_approve_no_duplicate_approval_marker_stack", "39_resources_unchanged_after_train_assign_signal_prepare_approve", "40_reserve_marker_no_movement_pathing_attack_deploy_behavior", "41_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare_approve", "42_field_barracks_no_engage_commit_hold_ashen_signal", "43_clear_guard_settles_defender_contact_clean_after_approve", "44_reguard_clean_after_approve_no_auto_deploy", "45_no_projectile_damage_hp_loss_death_despawn"
)
for ($i = 0; $i -lt $RuntimeTargets.Count; $i++) {
  $step = $i + 1
  $suffix = $RuntimeTargets[$i].Substring(3)
  $sourceName = ("{0:D2}_v0290_{1}_visible.png" -f $step, $suffix)
  $targetName = ("{0}_v0290_{1}.png" -f $RuntimeTargets[$i].Substring(0,2), $suffix)
  $sourcePath = Join-Path $OptInRuntimeRoot ("screenshots\" + $sourceName)
  $targetPath = Join-Path $ManualRoot $targetName
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.290 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0290BarrosanReserveDeploymentApprovalGateStepPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.290 visual evidence assembly failed." }
node tools/godot/saltoV0290BarrosanReserveDeploymentApprovalGateStepTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--true-default-root=$($TrueDefaultRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.290 report assembly failed." }
Write-Output "PASS_v0290_BARROSAN_RESERVE_DEPLOYMENT_APPROVAL_GATE_STEP_PACK_READY"