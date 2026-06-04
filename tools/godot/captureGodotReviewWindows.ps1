param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0121"
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
    throw "Refusing to remove screenshots outside v0.121 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

function Wait-ForCaptureArtifacts {
  param([int]$TimeoutSeconds = 90)
  $runtimeManifest = Join-Path $ArtifactRoot "screenshot-runtime-manifest.json"
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $pngCount = 0
    if (Test-Path $ScreenshotRoot) {
      $pngCount = @(Get-ChildItem -LiteralPath $ScreenshotRoot -Filter "*.png").Count
    }
    if ((Test-Path $runtimeManifest) -and $pngCount -eq 32) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  throw "Timed out waiting for screenshot-runtime-manifest.json and 32 PNG captures."
}

$RuntimeManifest = Join-Path $ArtifactRoot "screenshot-runtime-manifest.json"
Remove-Item -LiteralPath $RuntimeManifest -Force -ErrorAction SilentlyContinue
$CaptureArgs = @("--capture-review", "--artifact-root=$ArtifactArg")
& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs $CaptureArgs
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
Wait-ForCaptureArtifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" capture-review-v0121
