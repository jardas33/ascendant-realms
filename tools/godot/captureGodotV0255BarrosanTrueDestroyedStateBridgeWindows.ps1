param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0255"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0255-barrosan-true-destroyed-state-bridge"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0254-barrosan-damaged-functional-barracks-bridge\52_v0254_contact_sheet.png"
$Verdict = if ($env:V0255_VERDICT) { $env:V0255_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.254 damaged-functional baseline." }
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}
New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null
$ExePath = if ($env:V0255_EXE_PATH) { $env:V0255_EXE_PATH } else { Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe" }
if (-not $env:V0255_EXE_PATH) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing v0.255 capture executable: $ExePath" }
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "`"--artifact-root=$($DefaultRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.255 default capture failed." }
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.255 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0254_baseline_damaged_functional.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "03_v0255_default_runtime_unchanged_proof.png")
$Names = @(
 "opt_in_overview_before_build","starting_resources","select_worker_construction_available","valid_barracks_preview","confirm_authoritative_barracks_placement",
 "construction_resource_delta","field_barracks_hp_200","first_raider_spawned_once","first_warning_started","first_warning_midpoint_no_damage",
 "first_warning_expired","first_damage_hp_175","first_damage_hp_150","first_damage_hp_125","first_pressure_stops_at_125",
 "no_passive_collapse_after_wait","damaged_barracks_selectable","damaged_barracks_train_available","train_from_damaged_ordered",
 "train_from_damaged_resource_delta","militia_ready_from_damaged_barracks","damaged_barracks_still_hp_125_after_training",
 "second_pressure_triggered_explicitly","second_warning_started","second_warning_midpoint_no_damage","second_warning_expired_no_intercept",
 "second_damage_hp_100","second_damage_hp_75","second_damage_hp_50","second_damage_hp_25_still_functional","second_damage_hp_0_destroyed",
 "destroyed_barracks_selected","destroyed_barracks_train_unavailable","destroyed_barracks_repair_unavailable","no_refund_after_destruction",
 "train_from_damaged_intercepts_second_pressure_start","second_pressure_intercept_order","second_pressure_intercept_combat_90_40",
 "second_pressure_intercept_combat_80_20","second_pressure_intercept_combat_70_0","second_pressure_intercept_barracks_survives_125",
 "repair_branch_available_at_125","repair_resource_delta","repair_hp_150","repair_hp_175","repair_hp_200","repair_unavailable_full_hp",
 "defended_first_branch_start","defended_first_combat_90_40","defended_first_combat_80_20","defended_first_combat_70_0",
 "defended_barracks_unharmed_200","aster_worker_unharmed_proof","minimap_preserved","existing_barracks_preserved",
 "command_keep_lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0255_{1}.png" -f ($i + 4), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0255BarrosanTrueDestroyedStateReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.255 evidence assembly failed." }
node tools/godot/saltoV0255BarrosanTrueDestroyedStateBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.255 report assembly failed." }
Write-Output "PASS_V0255_BARROSAN_TRUE_DESTROYED_STATE_BRIDGE_REVIEW_PACK_READY"
