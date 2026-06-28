param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0262"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-awareness-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0262-barrosan-watchpost-awareness-layer"
$Verdict = if ($env:V0262_VERDICT) { $env:V0262_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:V0262_GODOT_PATH) { $env:V0262_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.262 capture Godot binary: $GodotPath" }

function Invoke-V0262RenderedCapture {
  param(
    [string[]] $Arguments,
    [string] $ManifestPath,
    [string] $Label,
    [bool] $ExpectSkinEnabled
  )
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.262 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.262 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.262"') { throw "Godot v0.262 $Label rendered capture did not dispatch v0.262 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.262 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.262 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.262 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0262/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0262/watchpost-awareness-runtime"

Invoke-V0262RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0262RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0262_watchpost_foundation_path_visible.png") (Join-Path $ManualRoot "02_v0262_default_runtime_unchanged_visible.png")

$Names = @(
 "v0262_watchpost_foundation_path_visible",
 "v0262_watchpost_complete_no_threat_visible",
 "v0262_watch_zone_clean_labeling_visible",
 "v0262_ashen_marker_outside_zone_no_false_positive_visible",
 "v0262_ashen_marker_touching_zone_scouted_visible",
 "v0262_ashen_marker_inside_zone_scouted_visible",
 "v0262_watchpost_selected_scouted_hud_visible",
 "v0262_watchpost_selected_no_attack_copy_visible",
 "v0262_minimap_scouted_threat_ping_visible",
 "v0262_barracks_hud_no_watchpost_text_visible",
 "v0262_watchpost_hud_no_barracks_text_visible",
 "v0262_barracks_still_trains_militia_visible",
 "v0262_existing_barracks_rebuild_path_still_valid_visible",
 "v0262_no_detection_before_watchpost_complete_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0262BarrosanWatchpostAwarenessPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.262 visual evidence assembly failed." }

node tools/godot/saltoV0262BarrosanWatchpostAwarenessTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.262 report assembly failed." }

Write-Output "PASS_V0262_BARROSAN_WATCHPOST_AWARENESS_PACK_READY"
