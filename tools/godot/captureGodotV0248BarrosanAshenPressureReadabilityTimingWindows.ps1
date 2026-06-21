param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0248"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0248-barrosan-ashen-pressure-readability-timing"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0247-barrosan-first-ashen-pressure-encounter\30_v0247_before_after_contact_sheet.png"
$Verdict = if ($env:V0248_VERDICT) { $env:V0248_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.247 PARTIAL baseline." }
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
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.248 default capture failed." }
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList @("--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.248 runtime capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0247_partial_baseline.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "03_v0248_default_runtime_unchanged_proof.png")
$Names = @(
  "opt_in_overview_before_build","starting_resources","select_builder_unit","valid_barracks_preview",
  "confirm_authoritative_barracks_placement","construction_resource_delta","select_new_field_barracks_hud",
  "prepare_one_defender_objective","train_militia_command_available","train_militia_resource_delta",
  "militia_training_progress_0","militia_training_progress_50","militia_ready_spawned","defender_ready_objective",
  "ashen_pressure_incoming_objective","pressure_telegraph_marker","ashen_raider_spawned_once",
  "ashen_raider_minimap_presence","ashen_raider_pressure_lane_start","ashen_raider_advancing_readable_timing",
  "select_spawned_militia_hud","intercept_zone_marker","militia_moves_to_intercept_zone",
  "militia_reaches_intercept_zone","pressure_contained_status","no_damage_no_resource_mutation_after_pressure",
  "command_keep_preserved","existing_barracks_train_flow_preserved","lume_mine_preserved",
  "shells_remain_non_producing","unselected_clean_view"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0248_{1}.png" -f ($i + 4), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0248BarrosanAshenPressureReadabilityTimingReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.248 evidence image assembly failed." }
node tools/godot/saltoV0248BarrosanAshenPressureReadabilityTimingTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.248 report assembly failed." }
Write-Output "PASS_V0248_BARROSAN_ASHEN_PRESSURE_READABILITY_TIMING_REVIEW_PACK_READY"
