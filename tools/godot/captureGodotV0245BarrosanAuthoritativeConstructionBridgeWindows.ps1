param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0245"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0245-barrosan-authoritative-construction-bridge"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0244-barrosan-limited-technical-playtest\02_v0244_playtest_overview.png"
$Verdict = if ($env:V0245_VERDICT) { $env:V0245_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.244 partial baseline." }
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
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.245 default capture failed." }
$RuntimeArgs = @("--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"")
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList $RuntimeArgs -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.245 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0244_partial_baseline.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "03_v0245_default_runtime_unchanged_proof.png")
$Copies = @(
  @("01_opt_in_overview_before_build.png", "04_v0245_opt_in_overview_before_build.png"),
  @("02_starting_resources.png", "05_v0245_starting_resources.png"),
  @("03_select_builder_unit.png", "06_v0245_select_builder_unit.png"),
  @("04_valid_preview_before_cancel.png", "07_v0245_valid_preview_before_cancel.png"),
  @("05_cancel_preview_resources_unchanged.png", "08_v0245_cancel_preview_resources_unchanged.png"),
  @("06_blocked_preview_real_reason.png", "09_v0245_blocked_preview_real_reason.png"),
  @("07_blocked_attempt_no_resource_mutation.png", "10_v0245_blocked_attempt_no_resource_mutation.png"),
  @("08_valid_preview_before_confirm.png", "11_v0245_valid_preview_before_confirm.png"),
  @("09_confirm_real_placement.png", "12_v0245_confirm_real_placement.png"),
  @("10_resource_delta_after_real_placement.png", "13_v0245_resource_delta_after_real_placement.png"),
  @("11_new_structure_registered_selected.png", "14_v0245_new_structure_registered_selected.png"),
  @("12_new_structure_minimap_presence.png", "15_v0245_new_structure_minimap_presence.png"),
  @("13_command_keep_live_hud_preserved.png", "16_v0245_command_keep_live_hud_preserved.png"),
  @("14_barracks_live_hud_and_train_preserved.png", "17_v0245_barracks_live_hud_and_train_preserved.png"),
  @("15_lume_mine_live_hud_preserved.png", "18_v0245_lume_mine_live_hud_preserved.png"),
  @("16_shell_forge_market_watchtower_preserved.png", "19_v0245_shell_forge_market_watchtower_preserved.png"),
  @("17_unit_pathing_near_new_structure.png", "20_v0245_unit_pathing_near_new_structure.png"),
  @("18_unselected_clean_view.png", "21_v0245_unselected_clean_view.png")
)
foreach ($Copy in $Copies) { Copy-Item (Join-Path $RuntimeRoot "screenshots\$($Copy[0])") (Join-Path $ManualRoot $Copy[1]) }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0245BarrosanAuthoritativeConstructionBridgeReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.245 evidence image assembly failed." }
node tools/godot/saltoV0245BarrosanAuthoritativeConstructionBridgeTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.245 report assembly failed." }
Write-Output "PASS_V0245_BARROSAN_AUTHORITATIVE_CONSTRUCTION_BRIDGE_REVIEW_PACK_READY"
