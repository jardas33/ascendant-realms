param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0258"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0258-barrosan-lifecycle-readability-pass"
$Verdict = if ($env:V0258_VERDICT) { $env:V0258_VERDICT } else { "PARTIAL" }
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
$ExePath = if ($env:V0258_EXE_PATH) { $env:V0258_EXE_PATH } else { Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe" }
if (-not $env:V0258_EXE_PATH) {
  & (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
  & (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
}
if (-not (Test-Path -LiteralPath $ExePath)) { throw "Missing v0.258 capture executable: $ExePath" }
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "`"--artifact-root=$($DefaultRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.258 default capture failed." }
$RuntimeProcess = Start-Process -FilePath $ExePath -ArgumentList @("--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "`"--artifact-root=$($RuntimeRoot.Replace('\','/'))`"") -Wait -PassThru -WindowStyle Hidden
if ($RuntimeProcess.ExitCode -ne 0) { throw "Godot v0.258 runtime capture failed." }
Copy-Item (Join-Path $DefaultRoot "screenshots\01_initial_select_aster_instruction.png") (Join-Path $ManualRoot "02_v0258_default_runtime_unchanged_proof.png")
$Names = @(
 "initial_select_aster_instruction","after_aster_select_worker_instruction","worker_place_barracks_instruction","valid_placement_instruction",
 "barracks_built_instruction_and_visual_full","hp_125_damaged_functional_instruction_and_visual","hp_25_critical_functional_instruction_and_visual",
 "hp_0_destroyed_instruction_and_visual","destroyed_no_select_aster_stale_text","worker_rebuild_instruction","worker_rebuild_hud_and_button",
 "rebuild_resource_delta","rebuild_progress_25_visual_text","rebuild_progress_50_visual_text","rebuild_progress_75_visual_text",
 "rebuild_complete_100_visual_text","train_available_after_rebuild","train_resource_delta_after_rebuild","militia_ready_defend_instruction",
 "repair_rebuild_separation_worker_text","defended_branch_preserved","minimap_preserved","existing_structures_preserved",
 "no_stale_rebuild_not_implemented_text","no_stale_select_aster_after_initial_phase"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0258_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0258BarrosanLifecycleReadabilityReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.258 evidence assembly failed." }
node tools/godot/saltoV0258BarrosanLifecycleReadabilityTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.258 report assembly failed." }
Write-Output "PASS_V0258_BARROSAN_LIFECYCLE_READABILITY_REVIEW_PACK_READY"
