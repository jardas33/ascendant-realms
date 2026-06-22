param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0256"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0256-barrosan-first-worker-rebuild-bridge"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0255-barrosan-true-destroyed-state-bridge\63_v0255_contact_sheet.png"
$Verdict = if ($env:V0256_VERDICT) { $env:V0256_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.255 destroyed-state baseline." }
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}
New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null
$ExePath = if ($env:V0256_EXE_PATH) { $env:V0256_EXE_PATH } else { Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe" }
if (-not $env:V0256_EXE_PATH) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing v0.256 capture executable: $ExePath" }
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "`"--artifact-root=$($DefaultRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.256 default capture failed." }
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.256 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0255_baseline_destroyed_state.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "03_v0256_default_runtime_unchanged_proof.png")
$Names = @(
 "opt_in_overview_before_build","starting_resources","select_worker_construction_available","valid_barracks_preview","confirm_authoritative_barracks_placement",
 "construction_resource_delta","field_barracks_hp_200","first_pressure_to_125","no_passive_collapse_at_125","second_pressure_triggered",
 "second_damage_hp_100","second_damage_hp_75","second_damage_hp_50","second_damage_hp_25_still_functional","second_damage_hp_0_destroyed",
 "destroyed_barracks_selected","destroyed_barracks_train_unavailable","worker_selected_rebuild_available","repair_unavailable_at_zero","rebuild_ordered",
 "rebuild_resource_delta","rebuild_progress_hp_25","rebuild_progress_hp_50","rebuild_progress_hp_75","rebuild_complete_hp_100",
 "rebuilt_barracks_selectable","rebuilt_barracks_train_available","train_from_rebuilt_ordered","train_from_rebuilt_resource_delta",
 "militia_ready_from_rebuilt_barracks","rebuilt_barracks_still_hp_100","worker_after_rebuild_repair_vs_rebuild_state",
 "rebuild_unavailable_when_no_destroyed_target","repair_available_at_damaged_nonzero_if_resources_allow","rebuild_unavailable_at_damaged_nonzero",
 "defended_first_pressure_start","defended_first_combat_90_40","defended_first_combat_80_20","defended_first_combat_70_0",
 "defended_barracks_unharmed_200","aster_worker_unharmed_proof","minimap_preserved","existing_barracks_preserved",
 "command_keep_lume_mine_preserved","shells_remain_non_producing","default_runtime_clean_after_opt_in_work","unselected_clean_view"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0256_{1}.png" -f ($i + 4), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0256BarrosanFirstWorkerRebuildReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.256 evidence assembly failed." }
node tools/godot/saltoV0256BarrosanFirstWorkerRebuildBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.256 report assembly failed." }
Write-Output "PASS_V0256_BARROSAN_FIRST_WORKER_REBUILD_BRIDGE_REVIEW_PACK_READY"
