param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0131"
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
    throw "Refusing to remove screenshots outside v0.131 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

foreach ($fileName in @(
  "headed-playability-smoke.json",
  "real-input-trace.json",
  "real-input-trace.md",
  "selection-proof.json",
  "movement-proof.json",
  "screenshot-manifest.json",
  "README.md"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForRealInputArtifacts {
  param([int]$TimeoutSeconds = 120)
  $requiredFiles = @(
    (Join-Path $ArtifactRoot "headed-playability-smoke.json"),
    (Join-Path $ArtifactRoot "real-input-trace.json"),
    (Join-Path $ArtifactRoot "selection-proof.json"),
    (Join-Path $ArtifactRoot "movement-proof.json"),
    (Join-Path $ArtifactRoot "screenshot-manifest.json")
  )
  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  while ((Get-Date) -lt $deadline) {
    $pngCount = 0
    if (Test-Path $ScreenshotRoot) {
      $pngCount = @(Get-ChildItem -LiteralPath $ScreenshotRoot -Filter "*.png").Count
    }
    $missing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -eq 0 -and $pngCount -eq 12) {
      return
    }
    Start-Sleep -Milliseconds 250
  }
  $stillMissing = @($requiredFiles | Where-Object { -not (Test-Path $_) })
  throw "Timed out waiting for v0.131 real-input artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--real-input-smoke", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForRealInputArtifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" real-input-v0131
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
