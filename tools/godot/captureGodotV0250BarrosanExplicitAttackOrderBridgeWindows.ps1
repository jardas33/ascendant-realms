param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0250"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0250-barrosan-explicit-attack-order-bridge"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0249-barrosan-first-bounded-combat-resolution\39_v0249_before_after_contact_sheet.png"
$Verdict = if ($env:V0250_VERDICT) { $env:V0250_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.249 PARTIAL baseline." }
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
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList @("--player-slice-capture", "`"--artifact-root=$($DefaultRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.250 default capture failed." }
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList @("--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.250 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0249_partial_baseline.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "03_v0250_default_runtime_unchanged_proof.png")
$Names = @(
 "opt_in_overview_before_build","starting_resources","select_builder_unit","valid_barracks_preview","confirm_authoritative_barracks_placement",
 "construction_resource_delta","select_new_field_barracks_hud","train_militia_command_available","train_militia_resource_delta","militia_training_progress",
 "militia_ready_spawned","select_spawned_militia_hp_100_attack_available","pressure_telegraph_marker_preserved","intercept_zone_marker_preserved",
 "ashen_raider_spawned_once_hp_full","raider_minimap_presence","select_militia_before_attack_order","attack_command_available","attack_targeting_mode",
 "raider_targeted_by_attack_order","attack_order_accepted_hud","militia_closing_to_raider","combat_contact_begins_after_order","combat_tick_1_hp_90_40",
 "combat_tick_2_hp_80_20","combat_tick_3_raider_hp_zero_militia_70","raider_defeated_or_removed","raider_minimap_removed_or_defeated",
 "pressure_contained_by_attack_order","no_resource_mutation_after_combat","no_building_damage_proof","aster_worker_unharmed_proof",
 "existing_barracks_train_flow_preserved","command_keep_preserved","lume_mine_preserved","shells_remain_non_producing","unselected_clean_view"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0250_{1}.png" -f ($i + 4), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0250BarrosanExplicitAttackOrderBridgeReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.250 evidence assembly failed." }
node tools/godot/saltoV0250BarrosanExplicitAttackOrderBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.250 report assembly failed." }
Write-Output "PASS_V0250_BARROSAN_EXPLICIT_ATTACK_ORDER_BRIDGE_REVIEW_PACK_READY"
