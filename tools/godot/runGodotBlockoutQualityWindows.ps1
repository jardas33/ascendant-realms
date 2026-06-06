param()

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ArtifactRoot = Join-Path $RepoRoot "artifacts\desktop-spikes\godot-salto\v0137"
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
    throw "Refusing to remove screenshots outside v0.137 artifact root: $($resolvedScreenshots.Path)"
  }
  Remove-Item -LiteralPath $ScreenshotRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ScreenshotRoot | Out-Null

foreach ($fileName in @(
  "headed-blockout-quality-smoke.json",
  "blockout-quality-smoke.json",
  "composition-readability-report.json",
  "silhouette-readability-report.json",
  "lighting-vfx-report.json",
  "camera-screen-use-report.json",
  "performance-smoke.json",
  "screenshot-manifest.json",
  "screenshot-hashes.json",
  "blockout-quality-validation.json",
  "blockout-quality-trace.json",
  "blockout-quality-trace.md",
  "blockout-comparison.md",
  "README.md"
)) {
  Remove-Item -LiteralPath (Join-Path $ArtifactRoot $fileName) -Force -ErrorAction SilentlyContinue
}

function Wait-ForV0137Artifacts {
  param([int]$TimeoutSeconds = 480)
  $requiredFiles = @(
    (Join-Path $ArtifactRoot "headed-blockout-quality-smoke.json"),
    (Join-Path $ArtifactRoot "blockout-quality-smoke.json"),
    (Join-Path $ArtifactRoot "composition-readability-report.json"),
    (Join-Path $ArtifactRoot "silhouette-readability-report.json"),
    (Join-Path $ArtifactRoot "lighting-vfx-report.json"),
    (Join-Path $ArtifactRoot "camera-screen-use-report.json"),
    (Join-Path $ArtifactRoot "performance-smoke.json"),
    (Join-Path $ArtifactRoot "blockout-quality-trace.json"),
    (Join-Path $ArtifactRoot "screenshot-manifest.json"),
    (Join-Path $ArtifactRoot "blockout-comparison.md"),
    (Join-Path $ArtifactRoot "README.md")
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
  throw "Timed out waiting for v0.137 blockout quality artifacts: $($stillMissing -join ', ')"
}

& (Join-Path $PSScriptRoot "launchGodotReviewWindows.ps1") -Wait -ReviewArgs @("--blockout-quality-smoke", "--artifact-root=$ArtifactArg")
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Wait-ForV0137Artifacts
node "desktop-spikes/godot-salto/tools/godotSpikeTool.mjs" blockout-quality-v0137
$ToolExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($ToolExitCode -ne 0) {
  exit $ToolExitCode
}
