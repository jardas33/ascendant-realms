param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0254"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0254-barrosan-damaged-functional-barracks-bridge"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0253-barrosan-first-worker-repair-bridge\49_v0253_repair_contact_sheet.png"
$Verdict = if ($env:V0254_VERDICT) { $env:V0254_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.253 PARTIAL baseline." }
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}
New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "`"--artifact-root=$($DefaultRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.254 default capture failed." }
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.254 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0253_partial_baseline.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "03_v0254_default_runtime_unchanged_proof.png")
$Names = @(
 "opt_in_overview_before_build","starting_resources","select_worker_construction_available","valid_barracks_preview","confirm_authoritative_barracks_placement",
 "construction_resource_delta","field_barracks_hp_200","raider_spawned_once_hp_full","raider_enters_threat_range","warning_window_started",
 "warning_midpoint_no_damage","warning_expired_no_intercept","damage_tick_1_hp_175","damage_tick_2_hp_150","damage_tick_3_hp_125",
 "damage_stopped_at_125","damaged_barracks_still_selectable","damaged_barracks_train_militia_available","train_from_damaged_barracks_ordered",
 "train_from_damaged_resource_delta","train_from_damaged_militia_ready","damaged_barracks_still_hp_125_after_training","no_passive_collapse_after_wait",
 "select_worker_repair_available","repair_order_accepted","repair_resource_delta","repair_tick_1_hp_150","repair_tick_2_hp_175",
 "repair_tick_3_hp_200","repair_complete_full_hp","repair_unavailable_full_hp","defended_branch_start","defended_train_militia_resource_delta",
 "defended_attack_order_accepted","defended_combat_tick_1_90_40","defended_combat_tick_2_80_20","defended_combat_tick_3_70_0",
 "defended_barracks_unharmed_hp_200","raider_count_one_proof","militia_count_one_defended_branch","aster_worker_unharmed_proof",
 "minimap_preserved","existing_barracks_train_flow_preserved","command_keep_preserved","lume_mine_preserved","shells_remain_non_producing",
 "default_runtime_clean_after_opt_in_work","unselected_clean_view"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0254_{1}.png" -f ($i + 4), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0254BarrosanDamagedFunctionalBarracksReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.254 evidence assembly failed." }
node tools/godot/saltoV0254BarrosanDamagedFunctionalBarracksBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.254 report assembly failed." }
Write-Output "PASS_V0254_BARROSAN_DAMAGED_FUNCTIONAL_BARRACKS_BRIDGE_REVIEW_PACK_READY"
