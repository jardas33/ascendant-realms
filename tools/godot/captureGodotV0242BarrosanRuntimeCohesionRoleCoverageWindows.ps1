param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0242"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0242-barrosan-runtime-cohesion-role-coverage"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0241-barrosan-playable-runtime-skin\02_v0241_runtime_skin_overview.png"
$Verdict = if ($env:V0242_VERDICT) { $env:V0242_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.241 partial baseline." }
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
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.242 default capture failed." }
$RuntimeArgs = "--player-slice-capture --salto-barrosan-playable-runtime-skin `"--artifact-root=$($RuntimeRoot.Replace('\','/'))`""
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList $RuntimeArgs -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.242 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0241_partial_baseline.png")
$Copies = @(
  @("01_runtime_cohesion_overview.png", "02_v0242_runtime_cohesion_overview.png"),
  @("02_terrain_road_river_cohesion.png", "04_v0242_barrosan_terrain_road_river_cohesion.png"),
  @("03_all_nine_roles_runtime_addressable.png", "05_v0242_all_nine_roles_runtime_addressable.png"),
  @("04_live_roles_preserved.png", "06_v0242_live_roles_preserved_main_barracks_mine.png"),
  @("05_inert_roles_selectable.png", "07_v0242_inert_roles_selectable_house_farm_lumber_blacksmith_watchtower_market.png"),
  @("06_selected_structure_clean_indicator.png", "08_v0242_selected_structure_clean_indicator.png"),
  @("07_unselected_clean_no_debug.png", "09_v0242_unselected_clean_no_debug_clutter.png"),
  @("08_valid_placement_preview.png", "10_v0242_valid_placement_preview.png"),
  @("09_blocked_placement_preview.png", "11_v0242_blocked_placement_preview.png"),
  @("10_units_near_buildings_scale.png", "12_v0242_units_near_buildings_scale.png"),
  @("11_minimap_role_presence.png", "13_v0242_minimap_or_review_role_presence.png")
)
Copy-Item (Join-Path $DefaultRoot "screenshots\01_runtime_cohesion_overview.png") (Join-Path $ManualRoot "03_v0242_default_runtime_unchanged_proof.png")
foreach ($Copy in $Copies) { Copy-Item (Join-Path $RuntimeRoot "screenshots\$($Copy[0])") (Join-Path $ManualRoot $Copy[1]) }
node tools/godot/saltoV0242BarrosanRuntimeCohesionRoleCoverageTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.242 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0242BarrosanRuntimeCohesionRoleCoverageReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.242 contact sheet failed." }
Write-Output "PASS_V0242_BARROSAN_RUNTIME_COHESION_ROLE_COVERAGE_REVIEW_PACK_READY"
