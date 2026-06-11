param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot

$V0216GroundSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0216\local-terrain-material-slot\barrosan_foothold_terrain_material_v0216_1024.png"
$V0216GroundMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0216\local-terrain-material-slot\barrosan_foothold_terrain_material_v0216_1024.metadata.json"
$V0216GroundExpectedSha256 = "8049b692b5d89d9abf5da39a79a31d8609ceb944dcb5695af8efc8553cd1eea3"
$V0175GroundSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0175\local-ground-material-slot\barrosan_foothold_ground_material_v0175_1024.png"
$V0175GroundMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0175\local-ground-material-slot\barrosan_foothold_ground_material_v0175_1024.metadata.json"
$V0175GroundExpectedSha256 = "818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8"
$MissingGroundSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0216\missing-source\barrosan_foothold_terrain_material_v0216_1024.png"

$GroundMode = "v0216-selected"
$ForwardArgs = @()
foreach ($arg in $RemainingArgs) {
  if ($arg -eq "--salto-presentation-reboot-use-v0175-ground") {
    $GroundMode = "v0175-previous"
  } elseif ($arg -eq "--salto-presentation-reboot-ground-missing-fallback") {
    $GroundMode = "v0216-missing-fallback"
  } elseif ($arg -eq "--salto-presentation-reboot-ground-hash-mismatch") {
    $GroundMode = "v0216-hash-mismatch"
  } else {
    $ForwardArgs += $arg
  }
}

$GroundSourcePath = $V0216GroundSourcePath
$GroundMetadataPath = $V0216GroundMetadataPath
$GroundExpectedSha256 = $V0216GroundExpectedSha256
$GroundUvScale = "0.48"
if ($GroundMode -eq "v0175-previous") {
  $GroundSourcePath = $V0175GroundSourcePath
  $GroundMetadataPath = $V0175GroundMetadataPath
  $GroundExpectedSha256 = $V0175GroundExpectedSha256
  $GroundUvScale = "0.56"
} elseif ($GroundMode -eq "v0216-missing-fallback") {
  $GroundSourcePath = $MissingGroundSourcePath
} elseif ($GroundMode -eq "v0216-hash-mismatch") {
  $GroundExpectedSha256 = "0000000000000000000000000000000000000000000000000000000000000000"
}

if ($GroundMode -ne "v0216-missing-fallback") {
  foreach ($path in @($GroundSourcePath, $GroundMetadataPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
      Write-Warning "Ground material path is unavailable; Godot runtime should fail closed to procedural fallback: $path"
    }
  }
}

$RebootArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto presentation reboot compact HUD",
  "--salto-ui-shell-experiment",
  "--salto-selection-command-panel",
  "--salto-production-objectives-log",
  "--salto-minimap-tooltip-accessibility",
  "--salto-presentation-reboot",
  "--ground-material-opt-in",
  "--ground-material-source=$($GroundSourcePath.Replace('\', '/'))",
  "--ground-material-metadata=$($GroundMetadataPath.Replace('\', '/'))",
  "--ground-material-expected-sha256=$GroundExpectedSha256",
  "--ground-material-uv-scale=$GroundUvScale"
)
if ($ForwardArgs) {
  $RebootArgs += $ForwardArgs
}

Write-Output "Launching v0.216 Salto presentation reboot experiment."
Write-Output "Scope: isolated opt-in shell-v2 review path; compact contextual HUD plus selected terrain material; no new production slot, no browser wiring."
Write-Output "Ground material mode: $GroundMode"
Write-Output "Selected ground material SHA-256: $GroundExpectedSha256"
Write-Output "Default launcher, prior UI launchers, procedural fallback and v0.175 ground material comparator remain preserved."

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait:$Wait @RebootArgs
