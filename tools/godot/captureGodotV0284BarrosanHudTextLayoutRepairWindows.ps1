param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0284"
$TrueDefaultRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0284"
$OptInRuntimeRoot = Join-Path $ArtifactRoot "hud-text-layout-repair-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0284-barrosan-hud-text-layout-repair"
$Verdict = if ($env:v0284_VERDICT) { $env:v0284_VERDICT } else { "PASS" }

Set-Location $RepoRoot
foreach ($Target in @($ArtifactRoot, $TrueDefaultRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    [System.IO.Directory]::Delete("\\?\$resolvedTarget", $true)
  }
}
New-Item -ItemType Directory -Force -Path $ArtifactRoot, $TrueDefaultRoot, $OptInRuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:v0284_GODOT_PATH) { $env:v0284_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.284 capture Godot binary: $GodotPath" }

function Invoke-v0284RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [string] $ExpectedCheckpoint, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.284 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.284 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($ExpectedCheckpoint -and $manifestRaw -notmatch ('"checkpoint"\s*:\s*"' + [regex]::Escape($ExpectedCheckpoint) + '"')) { throw "Godot v0.284 $Label capture did not dispatch $ExpectedCheckpoint." }
  if (-not $ExpectedCheckpoint -and $manifestRaw -match '"checkpoint"\s*:\s*"v0\.284"') { throw "Godot v0.284 $Label true-default capture accidentally dispatched the v0.284 review fixture." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.284 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -match '"enabled"\s*:\s*true') { throw "Godot v0.284 $Label rendered capture leaked the opt-in Barrosan runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.284 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$TrueDefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0284"
$OptInRuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0284/hud-text-layout-repair-runtime"

Invoke-v0284RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$TrueDefaultArgRoot") -ManifestPath (Join-Path $TrueDefaultRoot "screenshot-runtime-manifest.json") -Label "true default" -ExpectedCheckpoint "" -ExpectSkinEnabled $false
Invoke-v0284RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$OptInRuntimeArgRoot") -ManifestPath (Join-Path $OptInRuntimeRoot "screenshot-runtime-manifest.json") -Label "opt-in runtime" -ExpectedCheckpoint "v0.284" -ExpectSkinEnabled $true

Copy-Item (Join-Path $TrueDefaultRoot "screenshots\03_battle_default.png") (Join-Path $ManualRoot "02_v0284_true_default_runtime_baseline_no_fixture_no_opt_in.png")

$RuntimeCopies = @(
  @{ Source = "01_v0284_manual_fixture_baseline_clean_select_aster_visible.png"; Target = "04_v0284_manual_fixture_baseline_clean_select_aster.png" },
  @{ Source = "02_v0284_engage_available_before_click_visible.png"; Target = "05_v0284_engage_available_before_click_readable_hud.png" },
  @{ Source = "03_v0284_engage_armed_hud_clean_visible.png"; Target = "06_v0284_engage_armed_readable_hud.png" },
  @{ Source = "04_v0284_engage_armed_exactly_one_world_label_visible.png"; Target = "07_v0284_engage_armed_exactly_one_short_world_label.png" },
  @{ Source = "05_v0284_commit_engage_clicked_visible.png"; Target = "08_v0284_commit_engage_clicked_readable_hud.png" },
  @{ Source = "06_v0284_post_commit_player_pressure_checked_label_visible.png"; Target = "09_v0284_post_commit_pressure_checked_once_readable_hud.png" },
  @{ Source = "07_v0284_post_commit_ashen_braced_label_visible.png"; Target = "10_v0284_post_commit_ashen_braced_once_readable_hud.png" },
  @{ Source = "08_v0284_post_commit_combined_pressure_checked_ashen_braced_visible.png"; Target = "11_v0284_combined_labels_readable_hud.png" },
  @{ Source = "09_v0284_repeat_commit_no_stack_no_duplicate_ashen_braced_visible.png"; Target = "12_v0284_repeat_commit_no_duplicate_readable_hud.png" },
  @{ Source = "10_v0284_clear_guard_settles_ashen_response_visible.png"; Target = "13_v0284_clear_guard_settles_ashen_response_readable_hud.png" },
  @{ Source = "11_v0284_reguard_availability_clean_visible.png"; Target = "14_v0284_reguard_availability_clean_readable_hud.png" },
  @{ Source = "12_v0284_watchpost_no_engage_commit_ashen_braced_visible.png"; Target = "15_v0284_watchpost_no_engage_commit_ashen_braced_readable_hud.png" },
  @{ Source = "13_v0284_barracks_no_engage_commit_ashen_braced_visible.png"; Target = "16_v0284_barracks_no_engage_commit_ashen_braced_readable_hud.png" },
  @{ Source = "14_v0284_no_projectile_damage_death_despawn_visible.png"; Target = "17_v0284_no_projectile_damage_death_despawn_readable_hud.png" }
)
foreach ($copy in $RuntimeCopies) {
  $sourcePath = Join-Path $OptInRuntimeRoot ("screenshots\" + $copy.Source)
  $targetPath = Join-Path $ManualRoot $copy.Target
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.284 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0284BarrosanHudTextLayoutRepairPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.284 visual evidence assembly failed." }

node tools/godot/saltoV0284BarrosanHudTextLayoutRepairTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--true-default-root=$($TrueDefaultRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.284 report assembly failed." }

Write-Output "PASS_V0284_BARROSAN_HUD_TEXT_LAYOUT_REPAIR_PACK_READY"
