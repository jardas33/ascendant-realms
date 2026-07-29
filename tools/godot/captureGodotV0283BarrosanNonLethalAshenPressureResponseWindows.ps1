param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0283"
$TrueDefaultRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\true-default-runtime-baseline-lock-0283"
$OptInRuntimeRoot = Join-Path $ArtifactRoot "non-lethal-ashen-pressure-response-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0283-barrosan-non-lethal-ashen-pressure-response"
$Verdict = if ($env:v0283_VERDICT) { $env:v0283_VERDICT } else { "PASS" }

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

$GodotPath = if ($env:v0283_GODOT_PATH) { $env:v0283_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.283 capture Godot binary: $GodotPath" }

function Invoke-v0283RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [string] $ExpectedCheckpoint, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.283 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.283 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($ExpectedCheckpoint -and $manifestRaw -notmatch ('"checkpoint"\s*:\s*"' + [regex]::Escape($ExpectedCheckpoint) + '"')) { throw "Godot v0.283 $Label capture did not dispatch $ExpectedCheckpoint." }
  if (-not $ExpectedCheckpoint -and $manifestRaw -match '"checkpoint"\s*:\s*"v0\.283"') { throw "Godot v0.283 $Label true-default capture accidentally dispatched the v0.283 review fixture." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.283 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -match '"enabled"\s*:\s*true') { throw "Godot v0.283 $Label rendered capture leaked the opt-in Barrosan runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.283 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$TrueDefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0283"
$OptInRuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0283/non-lethal-ashen-pressure-response-runtime"

Invoke-v0283RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$TrueDefaultArgRoot") -ManifestPath (Join-Path $TrueDefaultRoot "screenshot-runtime-manifest.json") -Label "true default" -ExpectedCheckpoint "" -ExpectSkinEnabled $false
Invoke-v0283RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$OptInRuntimeArgRoot") -ManifestPath (Join-Path $OptInRuntimeRoot "screenshot-runtime-manifest.json") -Label "opt-in runtime" -ExpectedCheckpoint "v0.283" -ExpectSkinEnabled $true

Copy-Item (Join-Path $TrueDefaultRoot "screenshots\03_battle_default.png") (Join-Path $ManualRoot "02_v0283_true_default_runtime_baseline_no_fixture_no_opt_in.png")

$RuntimeCopies = @(
  @{ Source = "01_v0283_engage_available_before_click_visible.png"; Target = "04_v0283_engage_available_before_click.png" },
  @{ Source = "02_v0283_engage_armed_hud_clean_visible.png"; Target = "05_v0283_engage_armed_hud_clean.png" },
  @{ Source = "03_v0283_engage_armed_exactly_one_world_label_visible.png"; Target = "06_v0283_engage_armed_exactly_one_world_label.png" },
  @{ Source = "04_v0283_commit_engage_clicked_visible.png"; Target = "07_v0283_commit_engage_clicked.png" },
  @{ Source = "05_v0283_post_commit_player_pressure_checked_label_visible.png"; Target = "08_v0283_post_commit_player_pressure_checked_once.png" },
  @{ Source = "06_v0283_post_commit_ashen_braced_label_visible.png"; Target = "09_v0283_post_commit_ashen_braced_once.png" },
  @{ Source = "07_v0283_post_commit_combined_pressure_checked_ashen_braced_visible.png"; Target = "10_v0283_combined_pressure_checked_and_ashen_braced.png" },
  @{ Source = "08_v0283_repeat_commit_no_stack_no_duplicate_ashen_braced_visible.png"; Target = "11_v0283_repeat_commit_no_stack_no_duplicate_ashen_braced.png" },
  @{ Source = "09_v0283_clear_guard_settles_ashen_response_visible.png"; Target = "12_v0283_clear_guard_settles_ashen_response.png" },
  @{ Source = "10_v0283_reguard_availability_clean_visible.png"; Target = "13_v0283_reguard_availability_clean.png" },
  @{ Source = "11_v0283_watchpost_no_engage_commit_ashen_braced_visible.png"; Target = "14_v0283_watchpost_no_engage_commit_ashen_braced.png" },
  @{ Source = "12_v0283_barracks_no_engage_commit_ashen_braced_visible.png"; Target = "15_v0283_barracks_no_engage_commit_ashen_braced.png" },
  @{ Source = "13_v0283_no_projectile_damage_death_despawn_visible.png"; Target = "16_v0283_no_projectile_damage_death_despawn.png" }
)
foreach ($copy in $RuntimeCopies) {
  $sourcePath = Join-Path $OptInRuntimeRoot ("screenshots\" + $copy.Source)
  $targetPath = Join-Path $ManualRoot $copy.Target
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.283 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0283BarrosanNonLethalAshenPressureResponsePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.283 visual evidence assembly failed." }

node tools/godot/saltoV0283BarrosanNonLethalAshenPressureResponseTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--true-default-root=$($TrueDefaultRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.283 report assembly failed." }

Write-Output "PASS_V0283_BARROSAN_NON_LETHAL_ASHEN_PRESSURE_RESPONSE_PACK_READY"
