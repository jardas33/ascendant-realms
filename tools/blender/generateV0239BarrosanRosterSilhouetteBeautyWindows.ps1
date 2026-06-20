param()
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$Blender = "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe"
$Script = Join-Path $RepoRoot "tools\blender\generate_v0239_barrosan_roster_silhouette_beauty.py"
$Output = Join-Path $RepoRoot "desktop-spikes\godot-salto\assets\v0239\salto_barrosan_roster_silhouette_beauty.glb"
if (-not (Test-Path -LiteralPath $Blender)) { throw "Blender 5.1 not found at $Blender" }
New-Item -ItemType Directory -Force -Path (Split-Path $Output) | Out-Null
Push-Location $RepoRoot
try {
  & $Blender -b --python $Script -- --output $Output
  if ($LASTEXITCODE -ne 0) { throw "Blender v0.239 generation failed." }
} finally {
  Pop-Location
}
if (-not (Test-Path -LiteralPath $Output)) { throw "Missing v0.239 GLB." }
$Contract = @{
  schemaVersion = 1; checkpoint = "v0.239"
  blendPath = "art-source/blender/v0239/salto_barrosan_roster_silhouette_beauty.blend"
  glbPath = "desktop-spikes/godot-salto/assets/v0239/salto_barrosan_roster_silhouette_beauty.glb"
  sourceGenerator = "tools/blender/generate_v0239_barrosan_roster_silhouette_beauty.py"
  blenderUsed = $true; newV0239GlbExported = $true; existingV0238GlbModified = $false
  revisedBuildingModuleCount = 6; addedOrRevisedPropModuleCount = 6; newOrChangedMaterialCount = 6
  revisedBuildingModules = @("house_dwelling","farm_granary","lumber_carpenter_yard","blacksmith_forge","watchtower_defense","market_storehouse")
  addedOrRevisedPropModules = @("prop_laundry_bench","prop_grain_cart","prop_timber_a_frame","prop_forge_tool_rack","prop_coal_ore_pile","prop_watchtower_ladder")
  hardBoundaries = @{ gameplayChanged=$false; saveChanged=$false; economyLogicChanged=$false; selectionChanged=$false; pathingChanged=$false; collisionChanged=$false; browserRuntimeChanged=$false; defaultLauncherChanged=$false; newRuntimeArtSlots=0; downloadedAssets=0; generatedAiImages=0 }
}
$Contract | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath ([IO.Path]::ChangeExtension($Output, ".contract.json")) -Encoding UTF8
Write-Output "PASS_V0239_BLENDER_ROSTER_SILHOUETTE_BEAUTY"
