param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0124"
$ScreenshotRoot = Join-Path $ArtifactRoot "screenshots"
$ArtifactArg = $ArtifactRoot.Replace("\", "/")

Set-Location $RepoRoot

& (Join-Path $PSScriptRoot "exportGodotWindows.ps1")
& (Join-Path $PSScriptRoot "packageGodotWindows.ps1")

New-Item -ItemType Directory -Force -Path $ArtifactRoot | Out-Null
if (Test-Path $ScreenshotRoot) {
  $resolvedScreenshots = Resolve-Path -LiteralPath $ScreenshotRoot
  $resolvedArtifact = Resolve-Path -LiteralPath $ArtifactRoot
  if (-not ($resolvedScreenshots.Path.StartsWith($resolvedArtifact.Path))) {
    throw "Refusing to remove screenshots outside v0.124 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

function Wait-ForPlayerSliceCaptureArtifacts {
  param([int]$TimeoutSeconds = 90)
  $runtimeManifest = Join-Path $ArtifactRoot "screenshot-runtime-manifest.json"
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $pngCount = 0
    if (Test-Path $ScreenshotRoot) {
      $pngCount = @(Get-ChildItem -LiteralPath $ScreenshotRoot -Filter "*.png").Count
    }
    if ((Test-Path $runtimeManifest) -and $pngCount -eq 14) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  throw "Timed out waiting for screenshot-runtime-manifest.json and 14 PNG captures."
}

Remove-Item -LiteralPath (Join-Path $ArtifactRoot "screenshot-runtime-manifest.json") -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $ArtifactRoot "screenshot-manifest.json") -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $ArtifactRoot "screenshot-hashes.json") -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $ArtifactRoot "contact-sheet.svg") -Force -ErrorAction SilentlyContinue

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--player-slice-capture", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForPlayerSliceCaptureArtifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" player-slice-capture
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
