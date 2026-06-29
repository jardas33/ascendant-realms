param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0264"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-intel-relay-readability-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0264-barrosan-watchpost-intel-relay-readability"
$Verdict = if ($env:V0264_VERDICT) { $env:V0264_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:V0264_GODOT_PATH) { $env:V0264_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.264 capture Godot binary: $GodotPath" }

function Invoke-V0264RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.264 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.264 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.264"') { throw "Godot v0.264 $Label rendered capture did not dispatch v0.264 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.264 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.264 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.264 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0264/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0264/watchpost-intel-relay-readability-runtime"

Invoke-V0264RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0264RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0264_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0264_default_runtime_unchanged_visible.png")

$Names = @(
 "v0264_watchpost_build_path_visible",
 "v0264_watchpost_complete_no_threat_no_history_intel_relay_visible",
 "v0264_watch_zone_clean_labeling_visible",
 "v0264_ashen_outside_zone_no_false_positive_visible",
 "v0264_ashen_touching_zone_current_scouted_visible",
 "v0264_ashen_inside_zone_current_scouted_visible",
 "v0264_current_scouted_intel_relay_visible",
 "v0264_current_scouted_world_label_not_overlapping_watchpost_visible",
 "v0264_current_scouted_minimap_ping_visible",
 "v0264_threat_leaves_zone_last_seen_memory_visible",
 "v0264_last_seen_memory_intel_relay_visible",
 "v0264_last_seen_memory_world_marker_distinct_visible",
 "v0264_last_seen_memory_minimap_ping_distinct_visible",
 "v0264_memory_clearly_not_current_detection_visible",
 "v0264_watchpost_hud_no_barracks_text_visible",
 "v0264_barracks_hud_no_watchpost_text_visible",
 "v0264_barracks_still_trains_militia_visible",
 "v0264_existing_barracks_rebuild_path_still_valid_visible",
 "v0264_no_detection_or_memory_before_watchpost_complete_visible",
 "v0264_world_label_clutter_reduced_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0264BarrosanWatchpostIntelRelayReadabilityPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.264 visual evidence assembly failed." }

node tools/godot/saltoV0264BarrosanWatchpostIntelRelayReadabilityTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.264 report assembly failed." }

Write-Output "PASS_V0264_BARROSAN_WATCHPOST_INTEL_RELAY_READABILITY_PACK_READY"
