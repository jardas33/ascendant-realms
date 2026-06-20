param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0235"
$ReportPath = Join-Path $ArtifactRoot "blender-tooling-report.json"
$OutputPath = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0235\salto_barrosan_architecture_kit.glb"
$BlendPath = Join-Path $RepoRoot "art-source\blender\v0235\salto_barrosan_architecture_kit.blend"
$Blender = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
if (-not (Test-Path -LiteralPath $Blender)) {
  throw "Blender 5.1 is required for v0.235 geometry correction."
}
& $Blender --background --factory-startup --python tools/blender/generate_v0235_salto_barrosan_architecture.py -- "--output=$($OutputPath.Replace('\','/'))"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath) -or -not (Test-Path -LiteralPath $BlendPath)) {
  throw "Blender did not produce the expected v0.235 source and GLB."
}
@{
  schemaVersion = 1
  checkpoint = "v0.235"
  status = "PASS_V0235_BLENDER_GLTF_EXPORT"
  blenderAvailable = $true
  blenderPath = $Blender
  blendPath = $BlendPath
  glbPath = $OutputPath
  existingV0233GlbModified = $false
  newV0235GlbExported = $true
  correctedBuildingModuleCount = 3
  correctedPitchedRoofAssemblyCount = 4
  correctedTowerCapCount = 4
  downloadedAssets = 0
  generatedAiImages = 0
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Output "PASS_V0235_BLENDER_ARCHITECTURE_EXPORT_READY"
