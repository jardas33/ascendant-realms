param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0279"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "engage-armed-world-label-hard-fail-fix-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0279-barrosan-engage-armed-world-label-hard-fail-fix"
$Verdict = if ($env:v0279_VERDICT) { $env:v0279_VERDICT } else { "PASS" }

Set-Location $RepoRoot
foreach ($Target in @($ArtifactRoot, $ManualRoot)) {
  if (Test-Path -LiteralPath $Target) {
    $resolvedTarget = (Resolve-Path -LiteralPath $Target).Path
    $resolvedArtifacts = (Resolve-Path -LiteralPath (Join-Path $RepoRoot "artifacts")).Path
    if (-not $resolvedTarget.StartsWith($resolvedArtifacts, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Refusing to remove path outside artifacts: $resolvedTarget" }
    [System.IO.Directory]::Delete("\\?\$resolvedTarget", $true)
  }
}
New-Item -ItemType Directory -Force -Path $DefaultRoot, $RuntimeRoot, $ManualRoot | Out-Null

$GodotPath = if ($env:v0279_GODOT_PATH) { $env:v0279_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.279 capture Godot binary: $GodotPath" }

function Invoke-v0279RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.279 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.279 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.279"') { throw "Godot v0.279 $Label rendered capture did not dispatch v0.279 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.279 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.279 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.279 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0279/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0279/engage-armed-world-label-hard-fail-fix-runtime"
Invoke-v0279RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") -Label "default" -ExpectSkinEnabled $false
Invoke-v0279RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") -Label "runtime" -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0279_engage_available_before_click_visible.png") (Join-Path $ManualRoot "02_v0279_default_runtime_unchanged_visible.png")

$Names = @(
 "v0279_engage_available_before_click_visible",
 "v0279_engage_armed_exactly_one_label_visible",
 "v0279_engagement_contained_absent_close_visible",
 "v0279_bridge_held_absent_close_visible",
 "v0279_hud_full_state_single_world_label_visible",
 "v0279_repeat_engage_no_duplicate_label_visible",
 "v0279_repeat_engage_hud_already_armed_visible",
 "v0279_clear_guard_clean_cancel_label_visible",
 "v0279_reguard_available_again_visible",
 "v0279_reguard_rearm_exactly_one_label_visible",
 "v0279_watchpost_no_engage_action_visible",
 "v0279_barracks_no_engage_action_visible",
 "v0279_no_projectile_no_damage_visible",
 "v0279_default_runtime_unchanged_probe_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  $sourcePath = Join-Path $RuntimeRoot "screenshots\$source"
  $targetPath = Join-Path $ManualRoot $target
  $deadline = (Get-Date).AddSeconds(10)
  while (-not [System.IO.File]::Exists("\\?\$sourcePath") -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 100 }
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.279 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0279BarrosanEngageArmedWorldLabelHardFailFixPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.279 visual evidence assembly failed." }

node tools/godot/saltoV0279BarrosanEngageArmedWorldLabelHardFailFixTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.279 report assembly failed." }

Write-Output "PASS_V0279_BARROSAN_ENGAGE_ARMED_WORLD_LABEL_HARD_FAIL_FIX_PACK_READY"
