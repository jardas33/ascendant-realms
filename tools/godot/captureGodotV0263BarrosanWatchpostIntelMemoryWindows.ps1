param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0263"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-intel-memory-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0263-barrosan-watchpost-intel-memory"
$Verdict = if ($env:V0263_VERDICT) { $env:V0263_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:V0263_GODOT_PATH) { $env:V0263_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.263 capture Godot binary: $GodotPath" }

function Invoke-V0263RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.263 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.263 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.263"') { throw "Godot v0.263 $Label rendered capture did not dispatch v0.263 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.263 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.263 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.263 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0263/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0263/watchpost-intel-memory-runtime"

Invoke-V0263RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0263RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0263_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0263_default_runtime_unchanged_visible.png")

$Names = @(
 "v0263_watchpost_build_path_visible",
 "v0263_watchpost_complete_no_threat_no_history_visible",
 "v0263_watch_zone_clean_labeling_visible",
 "v0263_ashen_outside_zone_no_false_positive_visible",
 "v0263_ashen_touching_zone_current_scouted_visible",
 "v0263_ashen_inside_zone_current_scouted_visible",
 "v0263_current_scouted_minimap_ping_visible",
 "v0263_current_scouted_hud_intel_only_visible",
 "v0263_threat_leaves_zone_last_seen_memory_visible",
 "v0263_last_seen_memory_minimap_ping_visible",
 "v0263_last_seen_memory_world_marker_visible",
 "v0263_memory_clearly_not_current_detection_visible",
 "v0263_watchpost_hud_no_barracks_text_visible",
 "v0263_barracks_hud_no_watchpost_text_visible",
 "v0263_barracks_still_trains_militia_visible",
 "v0263_existing_barracks_rebuild_path_still_valid_visible",
 "v0263_no_detection_or_memory_before_watchpost_complete_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0263BarrosanWatchpostIntelMemoryPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.263 visual evidence assembly failed." }

node tools/godot/saltoV0263BarrosanWatchpostIntelMemoryTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.263 report assembly failed." }

Write-Output "PASS_V0263_BARROSAN_WATCHPOST_INTEL_MEMORY_PACK_READY"
