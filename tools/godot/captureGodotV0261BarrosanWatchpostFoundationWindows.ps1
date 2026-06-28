param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0261"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "watchpost-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0261-barrosan-watchpost-foundation"
$Verdict = if ($env:V0261_VERDICT) { $env:V0261_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:V0261_GODOT_PATH) { $env:V0261_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.261 capture Godot binary: $GodotPath" }

function Invoke-V0261RenderedCapture {
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
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.261 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.261 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.261"') { throw "Godot v0.261 $Label rendered capture did not dispatch v0.261 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.261 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.261 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.261 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0261/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0261/watchpost-runtime"

Invoke-V0261RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") `
  -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") `
  -Label "default" `
  -ExpectSkinEnabled $false

Invoke-V0261RenderedCapture `
  -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") `
  -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") `
  -Label "runtime" `
  -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0261_initial_select_aster_visible.png") (Join-Path $ManualRoot "02_v0261_default_runtime_unchanged_visible.png")

$Names = @(
 "v0261_initial_select_aster_visible",
 "v0261_after_aster_select_worker_visible",
 "v0261_place_field_barracks_visible",
 "v0261_field_barracks_built_visible",
 "v0261_new_objective_build_watchpost_visible",
 "v0261_worker_watchpost_button_visible",
 "v0261_watchpost_placement_cost_visible",
 "v0261_watchpost_valid_site_visible",
 "v0261_watchpost_built_resource_delta_visible",
 "v0261_watchpost_selected_hud_visible",
 "v0261_watch_zone_overlay_visible",
 "v0261_watchpost_minimap_marker_visible",
 "v0261_barracks_still_trains_militia_visible",
 "v0261_militia_training_after_watchpost_visible",
 "v0261_no_barracks_text_on_watchpost_visible",
 "v0261_no_watchpost_text_on_barracks_visible",
 "v0261_existing_barracks_rebuild_path_still_valid_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  Copy-Item (Join-Path $RuntimeRoot "screenshots\$source") (Join-Path $ManualRoot $target)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0261BarrosanWatchpostFoundationPack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.261 visual evidence assembly failed." }

node tools/godot/saltoV0261BarrosanWatchpostFoundationTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.261 report assembly failed." }

Write-Output "PASS_V0261_BARROSAN_WATCHPOST_FOUNDATION_PACK_READY"
