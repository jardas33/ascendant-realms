param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0241"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$SkinRoot = Join-Path $ArtifactRoot "runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0241-barrosan-playable-runtime-skin"
$Baseline = Join-Path $RepoRoot "artifacts\manual-review\v0240-barrosan-playable-art-integration\02_v0240_playable_art_overview.png"
$Verdict = if ($env:V0241_VERDICT) { $env:V0241_VERDICT } else { "PARTIAL" }
Set-Location $RepoRoot
if (-not (Test-Path -LiteralPath $Baseline)) { throw "Missing v0.240 baseline overview." }
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}
New-Item -ItemType Directory -Force -Path $DefaultRoot, $SkinRoot, $ManualRoot | Out-Null
& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$DefaultArgs = "--player-slice-capture `"--artifact-root=$($DefaultRoot.Replace('\','/'))`""
$DefaultProcess = Start-Process -FilePath $ExePath -ArgumentList $DefaultArgs -Wait -PassThru -WindowStyle Hidden
if ($DefaultProcess.ExitCode -ne 0) { throw "Godot v0.241 default-runtime capture failed." }
$SkinArgs = "--player-slice-capture --salto-barrosan-playable-runtime-skin `"--artifact-root=$($SkinRoot.Replace('\','/'))`""
$SkinProcess = Start-Process -FilePath $ExePath -ArgumentList $SkinArgs -Wait -PassThru -WindowStyle Hidden
if ($SkinProcess.ExitCode -ne 0) { throw "Godot v0.241 skin capture failed." }
Copy-Item $Baseline (Join-Path $ManualRoot "01_v0240_review_lane_baseline.png")
Copy-Item (Join-Path $SkinRoot "screenshots\01_runtime_overview.png") (Join-Path $ManualRoot "02_v0241_runtime_skin_overview.png")
Copy-Item (Join-Path $DefaultRoot "screenshots\01_runtime_overview.png") (Join-Path $ManualRoot "03_v0241_default_runtime_unchanged_proof.png")
Copy-Item (Join-Path $SkinRoot "screenshots\02_selected_building_indicator.png") (Join-Path $ManualRoot "04_v0241_selected_building_runtime_indicator.png")
Copy-Item (Join-Path $SkinRoot "screenshots\03_clean_unselected_state.png") (Join-Path $ManualRoot "05_v0241_unselected_buildings_clean_view.png")
Copy-Item (Join-Path $SkinRoot "screenshots\04_role_mapping_proof.png") (Join-Path $ManualRoot "06_v0241_runtime_role_mapping_proof.png")
Copy-Item (Join-Path $SkinRoot "screenshots\05_valid_placement_preview.png") (Join-Path $ManualRoot "07_v0241_valid_build_preview.png")
Copy-Item (Join-Path $SkinRoot "screenshots\06_blocked_placement_preview.png") (Join-Path $ManualRoot "08_v0241_blocked_build_preview.png")
Copy-Item (Join-Path $SkinRoot "screenshots\07_units_and_buildings_scale.png") (Join-Path $ManualRoot "09_v0241_units_near_buildings_scale.png")
node tools/godot/saltoV0241BarrosanPlayableRuntimeSkinTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.241 report assembly failed." }
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0241BarrosanPlayableRuntimeSkinReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.241 contact sheet failed." }
Write-Output "PASS_V0241_BARROSAN_PLAYABLE_RUNTIME_SKIN_REVIEW_PACK_READY"
