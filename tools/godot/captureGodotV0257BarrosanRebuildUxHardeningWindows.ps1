param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0257"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0257-barrosan-rebuild-ux-hardening"
$Verdict = if ($env:V0257_VERDICT) { $env:V0257_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}
New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null
$ExePath = if ($env:V0257_EXE_PATH) { $env:V0257_EXE_PATH } else { Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe" }
if (-not $env:V0257_EXE_PATH) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing v0.257 capture executable: $ExePath" }
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "`"--artifact-root=$($DefaultRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.257 default capture failed." }
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.257 runtime capture failed." }
Copy-Item (Join-Path $DefaultRoot "screenshots\01_opt_in_overview_before_build.png") (Join-Path $ManualRoot "02_v0257_default_runtime_unchanged_proof.png")
$Names = @(
 "opt_in_overview_before_build","starting_resources","barracks_built_hp_200","first_pressure_hp_125_damaged_functional_text",
 "hp_25_still_functional_text","hp_0_destroyed_text_corrected","destroyed_train_unavailable_text",
 "worker_selected_rebuild_available_text","worker_repair_unavailable_target_destroyed_text","rebuild_ordered",
 "rebuild_resource_delta","rebuild_progress_hp_25_text","rebuild_progress_hp_50_text","rebuild_progress_hp_75_text",
 "rebuild_complete_hp_100_text","rebuilt_train_available_text","train_from_rebuilt_resource_delta",
 "militia_from_rebuilt_ready","worker_rebuild_unavailable_after_rebuild",
 "worker_repair_available_or_insufficient_resources_after_rebuild","defended_branch_combat_preserved",
 "barracks_unharmed_after_defense","aster_worker_unharmed","minimap_preserved","existing_structures_preserved",
 "no_stale_rebuild_not_implemented_text"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0257_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0257BarrosanRebuildUxHardeningReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.257 evidence assembly failed." }
node tools/godot/saltoV0257BarrosanRebuildUxHardeningTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.257 report assembly failed." }
Write-Output "PASS_V0257_BARROSAN_REBUILD_UX_HARDENING_REVIEW_PACK_READY"
