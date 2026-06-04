param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $RepoRoot
$ExePath = Join-Path $RepoRoot "desktop-spikes\godot-salto\builds\AscendantRealmsGodotSalto.exe"
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\latest"
$PackageRoot = Join-Path $ArtifactRoot "package-staging"
$ZipPath = Join-Path $ArtifactRoot "AscendantRealmsGodotSalto-v0117-windows.zip"

if (-not (Test-Path $ExePath)) {
  node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" package
  exit 0
}

New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
if (Test-Path $PackageRoot) {
  $resolvedPackage = Resolve-Path -LiteralPath $PackageRoot
  $resolvedArtifact = Resolve-Path -LiteralPath $ArtifactRoot
  if (-not ($resolvedPackage.Path.StartsWith($resolvedArtifact.Path))) {
    throw "Refusing to remove package staging outside artifact root: $($resolvedPackage.Path)"
  }
  Remove-Item -LiteralPath $PackageRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $PackageRoot | Out-Null
Copy-Item -LiteralPath $ExePath -Destination $PackageRoot -Force
@"
@echo off
cd /d "%~dp0"
start "" "AscendantRealmsGodotSalto.exe"
"@ | Set-Content -Path (Join-Path $PackageRoot "RUN_GODOT_SALTO_SPIKE.bat") -Encoding ASCII

if (Test-Path $ZipPath) {
  Remove-Item -LiteralPath $ZipPath -Force
}
Compress-Archive -Path (Join-Path $PackageRoot "*") -DestinationPath $ZipPath -Force
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" package
