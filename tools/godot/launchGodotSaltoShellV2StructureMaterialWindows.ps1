param(
  [switch]$Wait,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RemainingArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$StructureFinishSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_1024.png"
$StructureFinishMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_1024.metadata.json"
$StructureFinishExpectedSha = "94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef"

Set-Location $RepoRoot

foreach ($path in @($StructureFinishSourcePath, $StructureFinishMetadataPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required v0.202 structure-finish material path: $path"
  }
}

$StructureMaterialArgs = @(
  "--experimental-review-mode-label=Experimental opt-in: Salto shell v2 Barrosan structure finish",
  "--salto-shell-v2-structure-material",
  "--structure-finish-material-opt-in",
  "--structure-finish-material-source=$($StructureFinishSourcePath.Replace('\', '/'))",
  "--structure-finish-material-metadata=$($StructureFinishMetadataPath.Replace('\', '/'))",
  "--structure-finish-material-expected-sha256=$StructureFinishExpectedSha",
  "--structure-finish-material-uv-scale=0.70"
)
if ($RemainingArgs) {
  $StructureMaterialArgs += $RemainingArgs
}

Write-Output "Launching v0.204 Salto shell v2 structure-shell material review."
Write-Output "Structure finish SHA: $StructureFinishExpectedSha"
Write-Output "QA scope: isolated shell-v2 structure surfaces only; no production runtime slot, no generated images, no browser wiring."
Write-Output "v0.203 environmental cohesion, legacy shell, and all prior launchers remain comparators/fallbacks; default launcher remains procedural."

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2EnvironmentalCohesionWindows.ps1") -Wait:$Wait @StructureMaterialArgs
