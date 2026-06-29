param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0265"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-advisory-objectives-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0265-barrosan-watchpost-advisory-objectives"
$Verdict = if ($env:V0265_VERDICT) { $env:V0265_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:V0265_GODOT_PATH) { $env:V0265_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.265 capture Godot binary: $GodotPath" }

function Invoke-V0265RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.265 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.265 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.265"') { throw "Godot v0.265 $Label rendered capture did not dispatch v0.265 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.265 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.265 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.265 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0265/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0265/watchpost-advisory-objectives-runtime"

Invoke-V0265RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0265RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0265_watchpost_build_path_visible.png") (Join-Path $ManualRoot "02_v0265_default_runtime_unchanged_visible.png")

$Names = @(
 "v0265_watchpost_build_path_visible",
 "v0265_watchpost_online_monitoring_objective_visible",
 "v0265_no_prior_intel_relay_visible",
 "v0265_ashen_outside_zone_monitoring_not_alarm_visible",
 "v0265_no_false_positive_outside_zone_visible",
 "v0265_current_detection_objective_prepare_defenders_visible",
 "v0265_current_detection_intel_relay_visible",
 "v0265_current_detection_world_label_clean_visible",
 "v0265_current_detection_minimap_ping_visible",
 "v0265_barracks_selected_current_detection_militia_advisory_visible",
 "v0265_barracks_train_militia_after_watchpost_advisory_visible",
 "v0265_threat_leaves_memory_objective_visible",
 "v0265_last_seen_memory_intel_relay_visible",
 "v0265_last_seen_memory_marker_distinct_visible",
 "v0265_last_seen_memory_minimap_ping_distinct_visible",
 "v0265_memory_not_current_detection_visible",
 "v0265_watchpost_hud_no_barracks_actions_visible",
 "v0265_barracks_hud_no_watchpost_relay_card_visible",
 "v0265_existing_barracks_rebuild_path_still_valid_visible",
 "v0265_no_detection_or_advisory_before_watchpost_complete_visible",
 "v0265_world_label_clutter_not_regressed_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0265BarrosanWatchpostAdvisoryObjectivesPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.265 visual evidence assembly failed." }

node tools/godot/saltoV0265BarrosanWatchpostAdvisoryObjectivesTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.265 report assembly failed." }

Write-Output "PASS_V0265_BARROSAN_WATCHPOST_ADVISORY_OBJECTIVES_PACK_READY"

