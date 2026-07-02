param()
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0276"
$DefaultRoot = Join-Path $ArtifactRoot "default-runtime"
$RuntimeRoot = Join-Path $ArtifactRoot "manual-engage-command-armature-runtime"
$ManualRoot = Join-Path $RepoRoot "artifacts\manual-review\v0276-barrosan-manual-engage-command-armature"
$Verdict = if ($env:v0276_VERDICT) { $env:v0276_VERDICT } else { "PARTIAL" }

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

$GodotPath = if ($env:v0276_GODOT_PATH) { $env:v0276_GODOT_PATH } else { Join-Path $RepoRoot ".tools\godot\Godot_v4.6.3-stable_win64.exe" }
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Missing v0.276 capture Godot binary: $GodotPath" }

function Invoke-v0276RenderedCapture {
  param([string[]] $Arguments, [string] $ManifestPath, [string] $Label, [bool] $ExpectSkinEnabled)
  & $GodotPath @Arguments
  $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
  $deadline = (Get-Date).AddSeconds(90)
  while (-not (Test-Path -LiteralPath $ManifestPath) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 200 }
  if (-not (Test-Path -LiteralPath $ManifestPath)) { throw "Godot v0.276 $Label rendered capture failed: missing manifest." }
  $manifestRaw = Get-Content -Raw -LiteralPath $ManifestPath
  if ($manifestRaw -notmatch '"status"\s*:\s*"PASS_PLAYER_SLICE_CAPTURE"') { throw "Godot v0.276 $Label rendered capture failed: manifest did not report PASS_PLAYER_SLICE_CAPTURE." }
  if ($manifestRaw -notmatch '"checkpoint"\s*:\s*"v0.276"') { throw "Godot v0.276 $Label rendered capture did not dispatch v0.276 proof steps." }
  if ($ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*true') { throw "Godot v0.276 $Label rendered capture did not enable opt-in Barrosan runtime." }
  if (-not $ExpectSkinEnabled -and $manifestRaw -notmatch '"enabled"\s*:\s*false') { throw "Godot v0.276 $Label rendered capture changed default runtime." }
  if ($exitCode -ne 0) { throw "Godot v0.276 $Label rendered capture exited with code $exitCode after writing manifest." }
}

$DefaultArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0276/default-runtime"
$RuntimeArgRoot = "../../artifacts/desktop-spikes/godot-salto/v0276/manual-engage-command-armature-runtime"
Invoke-v0276RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--artifact-root=$DefaultArgRoot") -ManifestPath (Join-Path $DefaultRoot "screenshot-runtime-manifest.json") -Label "default" -ExpectSkinEnabled $false
Invoke-v0276RenderedCapture -Arguments @("--path", ".\desktop-spikes\godot-salto", "--", "--player-slice-capture", "--salto-barrosan-playable-runtime-skin", "--artifact-root=$RuntimeArgRoot") -ManifestPath (Join-Path $RuntimeRoot "screenshot-runtime-manifest.json") -Label "runtime" -ExpectSkinEnabled $true

Copy-Item (Join-Path $DefaultRoot "screenshots\01_v0276_engage_unavailable_before_contact_visible.png") (Join-Path $ManualRoot "02_v0276_default_runtime_unchanged_visible.png")

$Names = @(
 "v0276_engage_unavailable_before_contact_visible",
 "v0276_engage_unavailable_militia_training_visible",
 "v0276_engage_unavailable_no_guard_order_visible",
 "v0276_engage_unavailable_guard_pending_visible",
 "v0276_engage_unavailable_guard_cleared_before_contact_visible",
 "v0276_engage_unavailable_not_holding_bridge_visible",
 "v0276_engage_unavailable_contact_not_resolved_visible",
 "v0276_engage_available_bridge_held_visible",
 "v0276_engage_available_engagement_contained_visible",
 "v0276_engage_click_arms_no_damage_visible",
 "v0276_engage_repeat_click_no_stack_no_damage_visible",
 "v0276_engage_armed_label_clean_visible",
 "v0276_engage_armed_hud_no_attack_projectile_damage_visible",
 "v0276_clear_guard_cancels_engage_visible",
 "v0276_reguard_engage_available_again_visible",
 "v0276_reguard_rearm_no_damage_visible",
 "v0276_watchpost_no_engage_action_visible",
 "v0276_barracks_no_engage_action_visible",
 "v0276_label_arbitration_retained_visible",
 "v0276_minimap_contact_ping_current_only_visible",
 "v0276_no_projectile_no_tower_visible",
 "v0276_no_auto_move_no_auto_attack_visible",
 "v0276_no_repeated_damage_below_90_visible",
 "v0276_default_runtime_unchanged_probe_visible",
 "v0276_existing_barracks_still_trains_militia_visible"
)
for ($i = 0; $i -lt $Names.Count; $i++) {
  $source = "{0:D2}_{1}.png" -f ($i + 1), $Names[$i]
  $target = "{0:D2}_{1}.png" -f ($i + 3), $Names[$i]
  $sourcePath = Join-Path $RuntimeRoot "screenshots\$source"
  $targetPath = Join-Path $ManualRoot $target
  $deadline = (Get-Date).AddSeconds(10)
  while (-not [System.IO.File]::Exists("\\?\$sourcePath") -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 100 }
  if (-not [System.IO.File]::Exists("\\?\$sourcePath")) { throw "Missing v0.276 runtime screenshot: $sourcePath" }
  [System.IO.File]::Copy("\\?\$sourcePath", "\\?\$targetPath", $true)
}

$Python = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (-not (Test-Path -LiteralPath $Python)) { $Python = "python" }
& $Python tools/godot/buildV0276BarrosanManualEngageCommandArmaturePack.py $ManualRoot
if ($LASTEXITCODE -ne 0) { throw "v0.276 visual evidence assembly failed." }

node tools/godot/saltoV0276BarrosanManualEngageCommandArmatureTool.mjs capture "--artifact-root=$($ArtifactRoot.Replace('\','/'))" "--verdict=$Verdict"
if ($LASTEXITCODE -ne 0) { throw "v0.276 report assembly failed." }

Write-Output "PASS_V0276_BARROSAN_MANUAL_ENGAGE_COMMAND_ARMATURE_PACK_READY"
