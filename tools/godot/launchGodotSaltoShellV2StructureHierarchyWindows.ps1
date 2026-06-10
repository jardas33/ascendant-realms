param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$BridgeRiverbankSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0189\local-bridge-riverbank-material-slot\barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png"
$BridgeRiverbankMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0189\local-bridge-riverbank-material-slot\barrosan_wet_granite_bridge_riverbank_material_v0189_1024.metadata.json"
$BridgeRiverbankExpectedSha = "638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753"

Set-Location $RepoRoot

foreach ($path in @($BridgeRiverbankSourcePath, $BridgeRiverbankMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required v0.198 wet-granite bridge-riverbank material path: $path"
  }
}

$StructureHierarchyArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto shell v2 structure hierarchy",
  "--salto-shell-v2-mesh-compositor",
  "--salto-shell-v2-structure-hierarchy",
  "--bridge-riverbank-material-opt-in",
  "--bridge-riverbank-material-source=$($BridgeRiverbankSourcePath.Replace('\', '/'))",
  "--bridge-riverbank-material-metadata=$($BridgeRiverbankMetadataPath.Replace('\', '/'))",
  "--bridge-riverbank-material-expected-sha256=$BridgeRiverbankExpectedSha",
  "--bridge-riverbank-material-uv-scale=0.70"
)
if ($RemainingArgs) {
  $StructureHierarchyArgs += $RemainingArgs
}

Write-Output "Launching v0.199 Salto shell v2 mesh-compositor structure hierarchy review."
Write-Output "Wet granite SHA: $BridgeRiverbankExpectedSha"
Write-Output "QA scope: procedural structure massing hardening only; no new images or slots."
Write-Output "Legacy shell remains available as comparator/fallback; default launcher remains procedural."

& (Join-Path $PSScriptRoot "launchGodotSaltoPresentationShellV2Windows.ps1") -Wait:$Wait @StructureHierarchyArgs
