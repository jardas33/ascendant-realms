param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0237"
$ReportPath = Join-Path $ArtifactRoot "blender-tooling-report.json"
$OutputPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0237\salto_barrosan_material_richness.glb"
$BlendPath = Join-Path $RepoRoot "art-source\blender\v0237\salto_barrosan_material_richness.blend"
$ContractPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0237\salto_barrosan_material_richness.contract.json"
$Blender = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputPath) | Out-Null
if (-not (Test-Path -LiteralPath $Blender)) {
  throw "Blender 5.1 is required for the v0.237 material-richness revision."
}
& $Blender --background --factory-startup --python tools/blender/generate_v0237_barrosan_material_richness.py -- "--output=$($OutputPath.Replace('\','/'))"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath) -or -not (Test-Path -LiteralPath $BlendPath)) {
  throw "Blender did not produce the expected v0.237 source and GLB."
}
$Export = Get-Content -Raw -LiteralPath ($OutputPath -replace '\.glb$', '.export.json') | ConvertFrom-Json
@{
  schemaVersion = 1
  checkpoint = "v0.237"
  sourceGenerator = "tools/blender/generate_v0237_barrosan_material_richness.py"
  blendPath = "art-source/blender/v0237/salto_barrosan_material_richness.blend"
  glbPath = "desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.glb"
  artBibleAddendumPath = "docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md"
  existingV0236GlbModified = $false
  newV0237GlbExported = $true
  newOrChangedMaterialCount = $Export.newOrChangedMaterialCount
  vegetationModules = $Export.vegetationModules
  vegetationModuleCount = $Export.vegetationModuleCount
  inhabitedPropModules = $Export.inhabitedPropModules
  inhabitedPropModuleCount = $Export.inhabitedPropModuleCount
  authoredBuildingDetailObjectCount = $Export.authoredBuildingDetailObjectCount
  roofGeometryContract = $Export.roofGeometryContract
  hardBoundaries = @{
    browserRuntimeChanged = $false
    gameplayChanged = $false
    saveChanged = $false
    pathingChanged = $false
    collisionChanged = $false
    defaultLauncherChanged = $false
    newRuntimeArtSlots = 0
    downloadedAssets = 0
    generatedAiImages = 0
  }
} | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath $ContractPath -Encoding UTF8
@{
  schemaVersion = 1
  checkpoint = "v0.237"
  status = "PASS_V0237_BLENDER_GLTF_EXPORT"
  blenderAvailable = $true
  blenderPath = $Blender
  blendPath = $BlendPath
  glbPath = $OutputPath
  existingV0236GlbModified = $false
  newV0237GlbExported = $true
  newOrChangedMaterialCount = $Export.newOrChangedMaterialCount
  vegetationModuleCount = $Export.vegetationModuleCount
  inhabitedPropModuleCount = $Export.inhabitedPropModuleCount
  authoredBuildingDetailObjectCount = $Export.authoredBuildingDetailObjectCount
  downloadedAssets = 0
  generatedAiImages = 0
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Output "PASS_V0237_BLENDER_MATERIAL_RICHNESS_READY"
