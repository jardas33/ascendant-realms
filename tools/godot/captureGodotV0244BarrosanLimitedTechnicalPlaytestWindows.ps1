param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0244"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0244-barrosan-limited-technical-playtest"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0243-barrosan-build-validation-role-shells\02_v0243_runtime_shell_overview.png"
$Verdict = if ($env:V0244_VERDICT) { $env:V0244_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.243 partial baseline." }
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
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.244 default capture failed." }
$RuntimeArgs = @("--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"")
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList $RuntimeArgs -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.244 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0243_partial_baseline.png")
Copy-Item (Join-Path $RuntimeRoot "screenshots\01_playtest_overview.png") (Join-Path $ManualRoot "02_v0244_playtest_overview.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_playtest_overview.png") (Join-Path $ManualRoot "03_v0244_default_runtime_unchanged_proof.png")
$Copies = @(
  @("02_select_aster.png", "05_v0244_select_aster.png"),
  @("03_unit_movement_road_probe.png", "06_v0244_unit_movement_road_probe.png"),
  @("04_unit_movement_bridge_probe.png", "07_v0244_unit_movement_bridge_probe.png"),
  @("05_select_command_keep_live_hud.png", "08_v0244_select_command_keep_live_hud.png"),
  @("06_select_barracks_live_hud.png", "09_v0244_select_barracks_live_hud.png"),
  @("07_barracks_restore_train_flow.png", "10_v0244_barracks_restore_train_flow.png"),
  @("08_select_lume_mine_live_hud.png", "11_v0244_select_lume_mine_live_hud.png"),
  @("09_select_shell_forge_hud.png", "12_v0244_select_shell_forge_hud.png"),
  @("10_select_shell_market_hud.png", "13_v0244_select_shell_market_hud.png"),
  @("11_valid_preview_real_validation.png", "14_v0244_valid_preview_real_validation.png"),
  @("12_blocked_preview_real_reason.png", "15_v0244_blocked_preview_real_reason.png"),
  @("13_resources_unchanged_after_preview.png", "16_v0244_resources_unchanged_after_preview.png"),
  @("14_minimap_all_roles_after_playtest.png", "17_v0244_minimap_all_roles_after_playtest.png"),
  @("15_unselected_clean_view.png", "18_v0244_unselected_clean_view.png")
)
foreach ($Copy in $Copies) { Copy-Item (Join-Path $RuntimeRoot "screenshots\$($Copy[0])") (Join-Path $ManualRoot $Copy[1]) }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0244BarrosanLimitedTechnicalPlaytestReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.244 evidence image assembly failed." }
node tools/godot/saltoV0244BarrosanLimitedTechnicalPlaytestTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.244 report assembly failed." }
Write-Output "PASS_V0244_BARROSAN_LIMITED_TECHNICAL_PLAYTEST_REVIEW_PACK_READY"
