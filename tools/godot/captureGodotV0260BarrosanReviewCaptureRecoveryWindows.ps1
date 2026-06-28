param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0260"
$DefaultRoot = Join-Path $ArtifactRoot "v0259-default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "v0259-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0260-barrosan-review-capture-recovery"
$Verdict = if ($env:V0260_VERDICT) { $env:V0260_VERDICT } else { "PARTIAL" }

Set-Location $RepoRoot

foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) {
      throw "Refusing to remove path outside artifacts: $resolvedTarget"
    }
    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
  }
}

New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:V0260_GODOT_PATH) { $env:V0260_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.260 capture Godot binary: $GodotPath" }

function Invoke-V0260RenderedCapture {
  param(
    [string[]] $Arguments,
    [string] $ManifestPath,
    [string] $Label
  )
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(60)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.260 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.260 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.259"') { throw "Godot v0.260 $Label rendered capture did not dispatch v0.259 proof steps." }
  if ($exitCode -ne 0) { throw "Godot v0.260 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0260/v0259-default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0260/v0259-runtime"

Invoke-V0260RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default"

Invoke-V0260RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime"

Copy-Item (Join-Path $DefaultRoot "screenshots\01_initial_select_aster_consistent.png") (Join-Path $ManualRoot "02_v0260_default_runtime_visible_not_black.png")

$Names = @(
 "initial_select_aster_consistent","after_aster_next_instruction_consistent","build_phase_no_rebuild_text","place_field_barracks_hud_button_consistent",
 "valid_placement_hud_button_consistent","barracks_built_full_consistent","hp_125_damaged_functional_consistent","hp_25_critical_functional_consistent",
 "hp_0_destroyed_consistent","destroyed_no_select_aster_no_stale_text","worker_selected_rebuild_consistent","worker_rebuild_button_only_when_destroyed",
 "rebuild_resource_delta","rebuilding_25_consistent","rebuilding_50_consistent","rebuilding_75_consistent","rebuilt_100_consistent",
 "train_available_after_rebuild_consistent","train_resource_delta_after_rebuild","militia_ready_defend_consistent","no_rebuild_text_after_rebuilt",
 "no_build_place_text_during_rebuild","repair_rebuild_separation_proof","visual_state_comparison_strip","minimap_preserved",
 "existing_structures_preserved","no_forbidden_text_scan"
)
$Targets = @(
 "opt_in_initial_select_aster_visible","after_aster_next_instruction_visible","build_phase_no_rebuild_text_visible","place_field_barracks_hud_button_visible",
 "valid_placement_hud_button_visible","barracks_built_full_visible","hp_125_damaged_functional_visible","hp_25_critical_functional_visible",
 "hp_0_destroyed_visible","destroyed_no_select_aster_no_stale_text_visible","worker_selected_rebuild_visible","worker_rebuild_button_only_when_destroyed_visible",
 "rebuild_resource_delta_visible","rebuilding_25_visible","rebuilding_50_visible","rebuilding_75_visible","rebuilt_100_visible",
 "train_available_after_rebuild_visible","train_resource_delta_after_rebuild_visible","militia_ready_defend_visible","no_rebuild_text_after_rebuilt_visible",
 "no_build_place_text_during_rebuild_visible","repair_rebuild_separation_visible","visual_state_comparison_strip_visible","minimap_preserved_visible",
 "existing_structures_preserved_visible","no_forbidden_text_scan"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0260_{1}.png" -f ($i + 3), $Targets[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0260BarrosanReviewCaptureRecoveryPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.260 visual evidence assembly failed." }

node tools/godot/saltoV0260BarrosanReviewCaptureRecoveryTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.260 report assembly failed." }

Write-Output "PASS_V0260_BARROSAN_REVIEW_CAPTURE_RECOVERY_PACK_READY"
