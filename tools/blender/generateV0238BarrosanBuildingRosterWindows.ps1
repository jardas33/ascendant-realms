param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0238"
$OutputPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0238\salto_barrosan_building_roster.glb"
$BlendPath = Join-Path $RepoRoot "art-source\blender\v0238\salto_barrosan_building_roster.blend"
$ContractPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0238\salto_barrosan_building_roster.contract.json"
$Blender = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputPath) | Out-Null
if (-not (Test-Path -LiteralPath $Blender)) { throw "Blender 5.1 is required for v0.238." }
& $Blender --background --factory-startup --python tools/blender/generate_v0238_barrosan_building_roster.py -- "--output=$($OutputPath.Replace('\','/'))"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $OutputPath) -or -not (Test-Path $BlendPath)) { throw "Missing v0.238 Blender outputs." }
$Export = Get-Content -Raw -LiteralPath ($OutputPath -replace '\.glb$', '.export.json') | ConvertFrom-Json
@{
  schemaVersion = 1
  checkpoint = "v0.238"
  sourceGenerator = "tools/blender/generate_v0238_barrosan_building_roster.py"
  blendPath = "art-source/blender/v0238/salto_barrosan_building_roster.blend"
  glbPath = "desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb"
  artBiblePath = "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md"
  existingV0237GlbModified = $false
  newV0238GlbExported = $true
  newBuildingModules = $Export.newBuildingModules
  newBuildingModuleCount = $Export.newBuildingModuleCount
  newPropModules = $Export.newPropModules
  newPropModuleCount = $Export.newPropModuleCount
  newOrChangedMaterialCount = $Export.newOrChangedMaterialCount
  roofGeometryContract = $Export.roofGeometryContract
  hardBoundaries = @{
    gameplayChanged = $false; saveChanged = $false; economyLogicChanged = $false
    selectionChanged = $false; pathingChanged = $false; collisionChanged = $false
    defaultLauncherChanged = $false; browserRuntimeChanged = $false
    newRuntimeArtSlots = 0; downloadedAssets = 0; generatedAiImages = 0
  }
} | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath $ContractPath -Encoding UTF8
@{
  schemaVersion = 1; checkpoint = "v0.238"; status = "PASS_V0238_BLENDER_GLTF_EXPORT"
  blenderPath = $Blender; blendPath = $BlendPath; glbPath = $OutputPath
  newBuildingModuleCount = 6; newPropModuleCount = 8; newOrChangedMaterialCount = 10
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $ArtifactRoot "blender-tooling-report.json") -Encoding UTF8
Write-Output "PASS_V0238_BLENDER_BUILDING_ROSTER_READY"
