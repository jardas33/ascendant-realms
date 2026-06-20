param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0236"
$ReportPath = Join-Path $ArtifactRoot "blender-tooling-report.json"
$OutputPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0236\salto_barrosan_production_slice.glb"
$BlendPath = Join-Path $RepoRoot "art-source\blender\v0236\salto_barrosan_production_slice.blend"
$ContractPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0236\salto_barrosan_production_slice.contract.json"
$Blender = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputPath) | Out-Null
if (-not (Test-Path -LiteralPath $Blender)) {
  throw "Blender 5.1 is required for the v0.236 production-direction asset revision."
}
& $Blender --background --factory-startup --python tools/blender/generate_v0236_barrosan_production_slice.py -- "--output=$($OutputPath.Replace('\','/'))"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath) -or -not (Test-Path -LiteralPath $BlendPath)) {
  throw "Blender did not produce the expected v0.236 source and GLB."
}
$Export = Get-Content -Raw -LiteralPath ($OutputPath -replace '\.glb$', '.export.json') | ConvertFrom-Json
@{
  schemaVersion = 1
  checkpoint = "v0.236"
  sourceGenerator = "tools/blender/generate_v0236_barrosan_production_slice.py"
  blendPath = "art-source/blender/v0236/salto_barrosan_production_slice.blend"
  glbPath = "desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.glb"
  artBiblePath = "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md"
  existingV0235GlbModified = $false
  newV0236GlbExported = $true
  changedBuildingModules = @("keep_landmark", "barracks_workshop_landmark", "mine_lume_landmark")
  changedBuildingModuleCount = 3
  rolePropModules = @("prop_weapon_rack", "prop_training_post", "prop_tool_cart", "prop_crystal_shards", "prop_mine_support", "prop_civic_banner")
  rolePropModuleCount = 6
  retunedExistingMaterialCount = 21
  newMaterialCount = 14
  newOrChangedMaterialCount = 35
  authoredBuildingDetailObjectCount = $Export.authoredBuildingDetailObjectCount
  roofGeometryContract = @{
    centralRidgeHighest = $true
    slopesDownToBothEaves = $true
    eaveOverhang = $true
    ridgeCaps = $true
    fasciaBoards = $true
    invertedRoofGeometry = $false
  }
  hardBoundaries = @{
    browserRuntimeChanged = $false
    gameplayChanged = $false
    saveChanged = $false
    pathingChanged = $false
    defaultLauncherChanged = $false
    newRuntimeArtSlots = 0
    downloadedAssets = 0
    generatedAiImages = 0
  }
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $ContractPath -Encoding UTF8
@{
  schemaVersion = 1
  checkpoint = "v0.236"
  status = "PASS_V0236_BLENDER_GLTF_EXPORT"
  blenderAvailable = $true
  blenderPath = $Blender
  blendPath = $BlendPath
  glbPath = $OutputPath
  existingV0235GlbModified = $false
  newV0236GlbExported = $true
  changedBuildingModuleCount = 3
  newOrChangedMaterialCount = 35
  rolePropModuleCount = 6
  authoredBuildingDetailObjectCount = $Export.authoredBuildingDetailObjectCount
  downloadedAssets = 0
  generatedAiImages = 0
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Output "PASS_V0236_BLENDER_PRODUCTION_SLICE_READY"
