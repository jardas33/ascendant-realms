param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0282"
$TrueDefaultRoot = Join-Path $ArtifactRoot "true-default-runtime"
$ManualFixtureRoot = Join-Path $ArtifactRoot "v0281-manual-review-fixture-source"
$OptInRuntimeRoot = Join-Path $ArtifactRoot "v0281-opt-in-readability-runtime-source"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0282-barrosan-default-runtime-baseline-lock"
$Verdict = if ($env:v0282_VERDICT) { $env:v0282_VERDICT } else { "PASS" }

Set-Location $RepoRoot
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    [System.IO.Directory]::Delete("\\?\$resolvedTarget", $true)
  }
}
New-Item -ItemType Directory -Force -Path $TrueDefaultRoot, $ManualFixtureRoot, $OptInRuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:v0282_GODOT_PATH) { $env:v0282_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.282 capture Godot binary: $GodotPath" }

function Invoke-v0282RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [bool] $ExpectSkinEnabled, [bool] $ExpectFixture)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.282 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.282 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($ExpectFixture -and $manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.281"') { throw "Godot v0.282 $Label fixture capture did not dispatch retained v0.281 proof steps." }
  if (-not $ExpectFixture -and $manifestRaw -match '"checkpoint"\s*:\s*"v0.281"') { throw "Godot v0.282 $Label true-default capture accidentally dispatched the v0.281 review fixture." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.282 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -match '"enabled"\s*:\s*true') { throw "Godot v0.282 $Label rendered capture leaked the opt-in Barrosan runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.282 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$TrueDefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0282/true-default-runtime"
$ManualFixtureArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0282/v0281-manual-review-fixture-source"
$OptInRuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0282/v0281-opt-in-readability-runtime-source"

Invoke-v0282RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$TrueDefaultArgRoot") -ManifestPath (Join-Path $TrueDefaultRoot "screenshot-runtime-manifest.json") -Label "true default" -ExpectSkinEnabled $false -ExpectFixture $false
Invoke-v0282RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$ManualFixtureArgRoot") -ManifestPath (Join-Path $ManualFixtureRoot "screenshot-runtime-manifest.json") -Label "manual review fixture" -ExpectSkinEnabled $false -ExpectFixture $true
Invoke-v0282RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$OptInRuntimeArgRoot") -ManifestPath (Join-Path $OptInRuntimeRoot "screenshot-runtime-manifest.json") -Label "opt-in readability runtime" -ExpectSkinEnabled $true -ExpectFixture $true

Copy-Item (Join-Path $TrueDefaultRoot "screenshots\03_battle_default.png") (Join-Path $ManualRoot "02_v0282_true_default_runtime_baseline_no_review_fixture.png")
Copy-Item (Join-Path $ManualFixtureRoot "screenshots\14_v0281_default_runtime_unchanged_probe_visible.png") (Join-Path $ManualRoot "04_v0282_barrosan_manual_review_fixture_baseline.png")
Copy-Item (Join-Path $OptInRuntimeRoot "screenshots\14_v0281_default_runtime_unchanged_probe_visible.png") (Join-Path $ManualRoot "05_v0282_opt_in_readability_runtime_baseline.png")

$RuntimeCopies = @(
  @{ Source = "01_v0281_engage_available_before_click_real_hud_only_visible.png"; Target = "06_v0282_engage_available_before_click_real_hud_only.png" },
  @{ Source = "02_v0281_engage_armed_real_hud_clean_visible.png"; Target = "07_v0282_engage_armed_real_hud_clean.png" },
  @{ Source = "03_v0281_engage_armed_exactly_one_world_label_visible.png"; Target = "08_v0282_engage_armed_exactly_one_world_label.png" },
  @{ Source = "05_v0281_commit_engage_clicked_visible.png"; Target = "09_v0282_commit_engage_clicked.png" },
  @{ Source = "06_v0281_post_commit_real_hud_clean_truthful_visible.png"; Target = "10_v0282_post_commit_real_hud_clean_truthful.png" },
  @{ Source = "07_v0281_post_commit_exactly_one_world_label_visible.png"; Target = "11_v0282_post_commit_exactly_one_world_label.png" },
  @{ Source = "08_v0281_repeat_commit_no_stack_real_hud_80_visible.png"; Target = "12_v0282_repeat_commit_no_pressure_stack.png" },
  @{ Source = "09_v0281_clear_guard_removes_commit_label_real_hud_clean_visible.png"; Target = "13_v0282_clear_guard_removes_commit_label.png" },
  @{ Source = "10_v0281_reguard_availability_clean_real_hud_visible.png"; Target = "14_v0282_reguard_availability_clean.png" },
  @{ Source = "11_v0281_watchpost_no_engage_commit_action_real_hud_visible.png"; Target = "15_v0282_watchpost_no_engage_commit_action.png" },
  @{ Source = "12_v0281_barracks_no_engage_commit_action_real_hud_visible.png"; Target = "16_v0282_barracks_no_engage_commit_action.png" },
  @{ Source = "13_v0281_no_projectile_unit_damage_enemy_death_visible.png"; Target = "17_v0282_no_projectile_no_damage_no_death_proof.png" }
)
foreach ($copy in $RuntimeCopies) {
  $sourcePath = Join-Path $OptInRuntimeRoot ("screenshots\" + $copy.Source)
  $targetPath = Join-Path $ManualRoot $copy.Target
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.282 retained runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0282BarrosanDefaultRuntimeBaselineLockPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.282 visual evidence assembly failed." }

node tools/godot/saltoV0282BarrosanDefaultRuntimeBaselineLockTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.282 report assembly failed." }

Write-Output "PASS_V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LOCK_PACK_READY"
