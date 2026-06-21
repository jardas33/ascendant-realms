param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0246"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0246-barrosan-field-barracks-production-bridge"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0245-barrosan-authoritative-construction-bridge\12_v0245_confirm_real_placement.png"
$Verdict = if ($env:V0246_VERDICT) { $env:V0246_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.245 partial baseline." }
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
$DefaultArgs = @("--player-slice-capture", "`"--artifact-root=$($DefaultRoot.Replace('\','/'))`"")
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList $DefaultArgs -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.246 default capture failed." }
$RuntimeArgs = @("--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"")
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList $RuntimeArgs -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.246 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0245_partial_baseline.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "03_v0246_default_runtime_unchanged_proof.png")
$Copies = @(
  @("01_opt_in_overview_before_build.png", "04_v0246_opt_in_overview_before_build.png"),
  @("02_starting_resources.png", "05_v0246_starting_resources.png"),
  @("03_select_builder_unit.png", "06_v0246_select_builder_unit.png"),
  @("04_valid_barracks_preview.png", "07_v0246_valid_barracks_preview.png"),
  @("05_confirm_authoritative_barracks_placement.png", "08_v0246_confirm_authoritative_barracks_placement.png"),
  @("06_construction_resource_delta.png", "09_v0246_construction_resource_delta.png"),
  @("07_select_new_field_barracks_hud.png", "10_v0246_select_new_field_barracks_hud.png"),
  @("08_train_militia_command_available.png", "11_v0246_train_militia_command_available.png"),
  @("09_train_militia_resource_delta.png", "12_v0246_train_militia_resource_delta.png"),
  @("10_militia_training_progress.png", "13_v0246_militia_training_progress.png"),
  @("11_militia_spawned_from_new_barracks.png", "14_v0246_militia_spawned_from_new_barracks.png"),
  @("12_select_spawned_militia.png", "15_v0246_select_spawned_militia.png"),
  @("13_move_spawned_militia_road_probe.png", "16_v0246_move_spawned_militia_road_probe.png"),
  @("14_move_spawned_militia_bridge_probe.png", "17_v0246_move_spawned_militia_bridge_probe.png"),
  @("15_failed_train_no_resource_mutation.png", "18_v0246_failed_train_no_resource_mutation.png"),
  @("16_new_barracks_and_militia_minimap_presence.png", "19_v0246_new_barracks_and_militia_minimap_presence.png"),
  @("17_existing_barracks_train_flow_preserved.png", "20_v0246_existing_barracks_train_flow_preserved.png"),
  @("18_command_keep_live_hud_preserved.png", "21_v0246_command_keep_live_hud_preserved.png"),
  @("19_lume_mine_live_hud_preserved.png", "22_v0246_lume_mine_live_hud_preserved.png"),
  @("20_shells_remain_non_producing.png", "23_v0246_shells_remain_non_producing.png"),
  @("21_unselected_clean_view.png", "24_v0246_unselected_clean_view.png")
)
foreach ($Copy in $Copies) { Copy-Item (Join-Path $RuntimeRoot "screenshots\$($Copy[0])") (Join-Path $ManualRoot $Copy[1]) }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0246BarrosanFieldBarracksProductionBridgeReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.246 evidence image assembly failed." }
node tools/godot/saltoV0246BarrosanFieldBarracksProductionBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.246 report assembly failed." }
Write-Output "PASS_V0246_BARROSAN_FIELD_BARRACKS_PRODUCTION_BRIDGE_REVIEW_PACK_READY"
