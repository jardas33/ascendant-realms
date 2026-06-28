param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0259"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "runtime"
$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0259/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0259/runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0259-barrosan-ui-state-invariant-hardening"
$Verdict = if ($env:V0259_VERDICT) { $env:V0259_VERDICT } else { "PARTIAL" }
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
$GodotPath = if ($env:V0259_GODOT_PATH) { $env:V0259_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.259 capture Godot binary: $GodotPath" }
function Invoke-V0259GodotCapture {
  param(
    [string[]] $Arguments,
    [string] $ManifestPath,
    [string] $Label
  )
  $stderrPath = Join-Path $ArtifactRoot ("godot-$Label-stderr.log")
  $stdoutPath = Join-Path $ArtifactRoot ("godot-$Label-stdout.log")
  $process = Start-Process -FilePath $GodotPath -ArgumentList $Arguments -Wait -PassThru -NoNewWindow -RedirectStandardError $stderrPath -RedirectStandardOutput $stdoutPath
  $deadline = (Get-Date).AddSeconds(10)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.259 $Label capture failed: missing manifest." }
  $manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
  if ($manifest.status -ne "PASS_PLAYER_SLICE_CAPTURE") { throw "Godot v0.259 $Label capture failed: $($manifest.status)" }
}
Invoke-V0259GodotCapture `
  -Arguments @("--headless", "--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default"
Invoke-V0259GodotCapture `
  -Arguments @("--headless", "--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime"
Copy-Item (Join-Path $DefaultRoot "screenshots\01_initial_select_aster_consistent.png") (Join-Path $ManualRoot "02_v0259_default_runtime_unchanged_proof.png")
$Names = @(
 "initial_select_aster_consistent","after_aster_next_instruction_consistent","build_phase_no_rebuild_text","place_field_barracks_hud_button_consistent",
 "valid_placement_hud_button_consistent","barracks_built_full_consistent","hp_125_damaged_functional_consistent","hp_25_critical_functional_consistent",
 "hp_0_destroyed_consistent","destroyed_no_select_aster_no_stale_text","worker_selected_rebuild_consistent","worker_rebuild_button_only_when_destroyed",
 "rebuild_resource_delta","rebuilding_25_consistent","rebuilding_50_consistent","rebuilding_75_consistent","rebuilt_100_consistent",
 "train_available_after_rebuild_consistent","train_resource_delta_after_rebuild","militia_ready_defend_consistent","no_rebuild_text_after_rebuilt",
 "no_build_place_text_during_rebuild","repair_rebuild_separation_proof","visual_state_comparison_strip","minimap_preserved",
 "existing_structures_preserved","no_forbidden_text_scan"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_v0259_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}
$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
& $Python tools/godot/buildV0259BarrosanUiStateInvariantReviewPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.259 evidence assembly failed." }
node tools/godot/saltoV0259BarrosanUiStateInvariantTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.259 report assembly failed." }
Write-Output "PASS_V0259_BARROSAN_UI_STATE_INVARIANT_REVIEW_PACK_READY"
