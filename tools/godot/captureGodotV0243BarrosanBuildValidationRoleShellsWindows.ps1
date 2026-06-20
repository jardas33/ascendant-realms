param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0243"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0243-barrosan-build-validation-role-shells"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0242-barrosan-runtime-cohesion-role-coverage\02_v0242_runtime_cohesion_overview.png"
$Verdict = if ($env:V0243_VERDICT) { $env:V0243_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.242 partial baseline." }
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
$DefaultArgs = "--player-slice-capture `"--artifact-root=$($DefaultRoot.Replace('\','/'))`""
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList $DefaultArgs -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.243 default capture failed." }
$RuntimeArgs = "--player-slice-capture --salto-barrosan-playable-runtime-skin `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList $RuntimeArgs -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.243 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0242_partial_baseline.png")
$Copies = @(
  @("01_runtime_shell_overview.png", "02_v0243_runtime_shell_overview.png"),
  @("02_all_nine_roles_registered.png", "04_v0243_all_nine_roles_registered.png"),
  @("03_live_entities_preserved.png", "05_v0243_live_entities_preserved.png"),
  @("04_shell_entities_selectable.png", "06_v0243_shell_entities_selectable.png"),
  @("05_selected_live_building_hud.png", "07_v0243_selected_live_building_hud.png"),
  @("06_selected_shell_building_hud.png", "08_v0243_selected_shell_building_hud.png"),
  @("07_valid_build_preview_real_validation.png", "09_v0243_valid_build_preview_real_validation.png"),
  @("08_blocked_build_preview_real_validation.png", "10_v0243_blocked_build_preview_real_validation.png"),
  @("09_validation_reason_overlay.png", "11_v0243_validation_reason_overlay.png"),
  @("10_units_pathing_near_shells.png", "12_v0243_units_pathing_near_shells.png"),
  @("11_minimap_all_roles.png", "13_v0243_minimap_all_roles.png"),
  @("12_unselected_clean_view.png", "14_v0243_unselected_clean_view.png")
)
Copy-Item (Join-Path $DefaultRoot "screenshots\01_runtime_shell_overview.png") (Join-Path $ManualRoot "03_v0243_default_runtime_unchanged_proof.png")
foreach ($Copy in $Copies) { Copy-Item (Join-Path $RuntimeRoot "screenshots\$($Copy[0])") (Join-Path $ManualRoot $Copy[1]) }
node tools/godot/saltoV0243BarrosanBuildValidationRoleShellsTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.243 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0243BarrosanBuildValidationRoleShellsReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.243 contact sheet failed." }
Write-Output "PASS_V0243_BARROSAN_BUILD_VALIDATION_ROLE_SHELLS_REVIEW_PACK_READY"
