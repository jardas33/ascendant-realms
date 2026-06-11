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
$V0217MaterialRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0217\local-road-riverbank-water-material-slot"
$V0217MissingRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0217\missing-road-riverbank-water-source"
$V0217RoadSourcePath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_road_1024.png"
$V0217RoadMetadataPath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_road_1024.metadata.json"
$V0217RoadExpectedSha256 = "14de8b84468d66a582f0cf1e5fb9ee82b59ca1d37da7589c21b2673ca5417a0b"
$V0217RiverbankSourcePath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_riverbank_1024.png"
$V0217RiverbankMetadataPath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_riverbank_1024.metadata.json"
$V0217RiverbankExpectedSha256 = "68b18047ae1dc501d51b57caf2cb118aa7f8b6167d887c83e0f9d5b05d5611ee"
$V0217WaterSourcePath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_water_1024.png"
$V0217WaterMetadataPath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_water_1024.metadata.json"
$V0217WaterExpectedSha256 = "461e7368d4084d474ce8471ea993633dfc5651a6cfda346ab3c184cf899cfbb9"
$V0217WetEdgeSourcePath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_wet_edge_1024.png"
$V0217WetEdgeMetadataPath = Join-Path $V0217MaterialRoot "barrosan_road_riverbank_water_material_v0217_wet_edge_1024.metadata.json"
$V0217WetEdgeExpectedSha256 = "c015bc67f5e9368532f0d449034f874d78da4b4e0156fbd60ec40ea6eadcc4da"
$V0202StructureFinishSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_1024.png"
$V0202StructureFinishMetadataPath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_1024.metadata.json"
$V0202StructureFinishExpectedSha256 = "94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef"
$MissingStructureFinishSourcePath = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0204\missing-structure-finish-source\barrosan_structure_finish_material_v0202_1024.png"

$GroundMode = "v0216-selected"
$RoadRiverbankWaterMode = "v0217-selected"
$BridgeShellMode = "v0218-selected"
$StructureFinishMode = "v0202-selected"
$StructureShellMode = "v0219-selected"
$ForwardArgs = @()
foreach ($arg in $RemainingArgs) {
  if ($arg -eq "--salto-presentation-reboot-use-v0175-ground") {
    $GroundMode = "v0175-previous"
  } elseif ($arg -eq "--salto-presentation-reboot-ground-missing-fallback") {
    $GroundMode = "v0216-missing-fallback"
  } elseif ($arg -eq "--salto-presentation-reboot-ground-hash-mismatch") {
    $GroundMode = "v0216-hash-mismatch"
  } elseif ($arg -eq "--salto-presentation-reboot-road-riverbank-water-missing-fallback") {
    $RoadRiverbankWaterMode = "v0217-missing-fallback"
  } elseif ($arg -eq "--salto-presentation-reboot-road-riverbank-water-hash-mismatch") {
    $RoadRiverbankWaterMode = "v0217-hash-mismatch"
  } elseif ($arg -eq "--salto-presentation-reboot-legacy-bridge" -or $arg -eq "--salto-bridge-shell-legacy-comparator") {
    $BridgeShellMode = "v0218-legacy-comparator"
  } elseif ($arg -eq "--salto-presentation-reboot-legacy-structures" -or $arg -eq "--salto-structure-shell-legacy-comparator") {
    $StructureShellMode = "v0219-legacy-comparator"
  } elseif ($arg -eq "--salto-structure-finish-material-missing-fallback") {
    $StructureFinishMode = "v0202-missing-fallback"
  } elseif ($arg -eq "--salto-structure-finish-material-hash-mismatch") {
    $StructureFinishMode = "v0202-hash-mismatch"
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

$RoadSourcePath = $V0217RoadSourcePath
$RoadMetadataPath = $V0217RoadMetadataPath
$RoadExpectedSha256 = $V0217RoadExpectedSha256
$RiverbankSourcePath = $V0217RiverbankSourcePath
$RiverbankMetadataPath = $V0217RiverbankMetadataPath
$RiverbankExpectedSha256 = $V0217RiverbankExpectedSha256
$WaterSourcePath = $V0217WaterSourcePath
$WaterMetadataPath = $V0217WaterMetadataPath
$WaterExpectedSha256 = $V0217WaterExpectedSha256
$WetEdgeSourcePath = $V0217WetEdgeSourcePath
$WetEdgeMetadataPath = $V0217WetEdgeMetadataPath
$WetEdgeExpectedSha256 = $V0217WetEdgeExpectedSha256
$RoadRiverbankWaterFallbackMode = "none"
if ($RoadRiverbankWaterMode -eq "v0217-missing-fallback") {
  $RoadRiverbankWaterFallbackMode = "missing"
  $RoadSourcePath = Join-Path $V0217MissingRoot "barrosan_road_riverbank_water_material_v0217_road_1024.png"
  $RiverbankSourcePath = Join-Path $V0217MissingRoot "barrosan_road_riverbank_water_material_v0217_riverbank_1024.png"
  $WaterSourcePath = Join-Path $V0217MissingRoot "barrosan_road_riverbank_water_material_v0217_water_1024.png"
  $WetEdgeSourcePath = Join-Path $V0217MissingRoot "barrosan_road_riverbank_water_material_v0217_wet_edge_1024.png"
} elseif ($RoadRiverbankWaterMode -eq "v0217-hash-mismatch") {
  $RoadRiverbankWaterFallbackMode = "hash-mismatch"
  $RoadExpectedSha256 = "0000000000000000000000000000000000000000000000000000000000000000"
}

$StructureFinishSourcePath = $V0202StructureFinishSourcePath
$StructureFinishMetadataPath = $V0202StructureFinishMetadataPath
$StructureFinishExpectedSha256 = $V0202StructureFinishExpectedSha256
$StructureFinishFallbackMode = "none"
if ($StructureFinishMode -eq "v0202-missing-fallback") {
  $StructureFinishFallbackMode = "missing"
  $StructureFinishSourcePath = $MissingStructureFinishSourcePath
} elseif ($StructureFinishMode -eq "v0202-hash-mismatch") {
  $StructureFinishFallbackMode = "hash-mismatch"
  $StructureFinishExpectedSha256 = "0000000000000000000000000000000000000000000000000000000000000000"
}

if ($GroundMode -ne "v0216-missing-fallback") {
  foreach ($path in @($GroundSourcePath, $GroundMetadataPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
      Write-Warning "Ground material path is unavailable; Godot runtime should fail closed to procedural fallback: $path"
    }
  }
}

if ($RoadRiverbankWaterMode -ne "v0217-missing-fallback") {
  foreach ($path in @($RoadSourcePath, $RoadMetadataPath, $RiverbankSourcePath, $RiverbankMetadataPath, $WaterSourcePath, $WaterMetadataPath, $WetEdgeSourcePath, $WetEdgeMetadataPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
      Write-Warning "Road/riverbank/water material path is unavailable; Godot runtime should fail closed to procedural fallback: $path"
    }
  }
}

if ($StructureFinishMode -ne "v0202-missing-fallback") {
  foreach ($path in @($StructureFinishSourcePath, $StructureFinishMetadataPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
      Write-Warning "Structure-finish material path is unavailable; Godot runtime should fail closed to procedural fallback: $path"
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
  "--ground-material-uv-scale=$GroundUvScale",
  "--road-riverbank-water-material-opt-in",
  "--road-riverbank-water-material-fallback-mode=$RoadRiverbankWaterFallbackMode",
  "--road-riverbank-water-road-source=$($RoadSourcePath.Replace('\', '/'))",
  "--road-riverbank-water-road-metadata=$($RoadMetadataPath.Replace('\', '/'))",
  "--road-riverbank-water-road-expected-sha256=$RoadExpectedSha256",
  "--road-riverbank-water-road-uv-scale=0.70",
  "--road-riverbank-water-riverbank-source=$($RiverbankSourcePath.Replace('\', '/'))",
  "--road-riverbank-water-riverbank-metadata=$($RiverbankMetadataPath.Replace('\', '/'))",
  "--road-riverbank-water-riverbank-expected-sha256=$RiverbankExpectedSha256",
  "--road-riverbank-water-riverbank-uv-scale=0.64",
  "--road-riverbank-water-water-source=$($WaterSourcePath.Replace('\', '/'))",
  "--road-riverbank-water-water-metadata=$($WaterMetadataPath.Replace('\', '/'))",
  "--road-riverbank-water-water-expected-sha256=$WaterExpectedSha256",
  "--road-riverbank-water-water-uv-scale=0.58",
  "--road-riverbank-water-wet-edge-source=$($WetEdgeSourcePath.Replace('\', '/'))",
  "--road-riverbank-water-wet-edge-metadata=$($WetEdgeMetadataPath.Replace('\', '/'))",
  "--road-riverbank-water-wet-edge-expected-sha256=$WetEdgeExpectedSha256",
  "--road-riverbank-water-wet-edge-uv-scale=0.60",
  "--salto-bridge-shell-reboot",
  "--salto-shell-v2-structure-material",
  "--structure-finish-material-opt-in",
  "--structure-finish-material-source=$($StructureFinishSourcePath.Replace('\', '/'))",
  "--structure-finish-material-metadata=$($StructureFinishMetadataPath.Replace('\', '/'))",
  "--structure-finish-material-expected-sha256=$StructureFinishExpectedSha256",
  "--structure-finish-material-fallback-mode=$StructureFinishFallbackMode",
  "--structure-finish-material-uv-scale=0.70",
  "--salto-structure-shell-production"
)
if ($BridgeShellMode -eq "v0218-legacy-comparator") {
  $RebootArgs += "--salto-bridge-shell-legacy-comparator"
}
if ($StructureShellMode -eq "v0219-legacy-comparator") {
  $RebootArgs += "--salto-structure-shell-legacy-comparator"
}
if ($ForwardArgs) {
  $RebootArgs += $ForwardArgs
}

Write-Output "Launching v0.219 Salto presentation reboot experiment."
Write-Output "Scope: isolated opt-in shell-v2 review path; compact contextual HUD plus selected terrain, road, riverbank, water, bridge and structure shell hierarchy; no new production slot, no browser wiring."
Write-Output "Ground material mode: $GroundMode"
Write-Output "Selected ground material SHA-256: $GroundExpectedSha256"
Write-Output "Road/riverbank/water material mode: $RoadRiverbankWaterMode"
Write-Output "Selected v0.217 material SHA-256 values: road=$RoadExpectedSha256 riverbank=$RiverbankExpectedSha256 water=$WaterExpectedSha256 wet-edge=$WetEdgeExpectedSha256"
Write-Output "Bridge shell mode: $BridgeShellMode"
Write-Output "Structure shell mode: $StructureShellMode"
Write-Output "Structure-finish material mode: $StructureFinishMode"
Write-Output "Selected v0.202 structure-finish SHA-256: $StructureFinishExpectedSha256"
Write-Output "Default launcher, prior UI launchers, procedural fallback and v0.175 ground material comparator remain preserved."

& (Join-Path $PSScriptRoot "launchGodotSaltoShellV2GroundingPropsWindows.ps1") -Wait:$Wait @RebootArgs
